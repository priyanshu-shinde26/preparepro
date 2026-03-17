require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Groq = require('groq-sdk');
const admin = require('firebase-admin');

// ── Firebase Admin Init ───────────────────────────────────────────────────────
// Uses GOOGLE_APPLICATION_CREDENTIALS env var on Render
// OR serviceAccountKey.json for local development
let firebaseInitialized = false;
try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    // On Render: paste entire JSON as env variable FIREBASE_SERVICE_ACCOUNT
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  } else {
    // Local development: use serviceAccountKey.json file
    const serviceAccount = require('./serviceAccountKey.json');
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  }
  firebaseInitialized = true;
  console.log('Firebase Admin initialized successfully');
} catch (err) {
  console.error('Firebase Admin init failed:', err.message);
  console.log('Running WITHOUT auth verification (development mode)');
}

// ── Groq Client ───────────────────────────────────────────────────────────────
const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
  timeout: 60000, // 60 second timeout for Groq calls
});

// ── Express App ───────────────────────────────────────────────────────────────
const app = express();

// ── CORS — allow all origins (Flutter web + mobile) ──────────────────────────
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: false,
}));

// Handle preflight OPTIONS requests
app.options('*', cors());

app.use(express.json({ limit: '10mb' }));

// ── Request logger ────────────────────────────────────────────────────────────
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// ── Auth Middleware ───────────────────────────────────────────────────────────
const authenticate = async (req, res, next) => {
  // Skip auth if Firebase not initialized (dev mode)
  if (!firebaseInitialized) return next();

  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: 'No auth token. Please log in again.' });
  }

  try {
    req.user = await admin.auth().verifyIdToken(token);
    next();
  } catch (err) {
    console.error('Token verification failed:', err.message);
    return res.status(401).json({
      error: 'Session expired. Please log out and log in again.',
    });
  }
};

// ── Groq helper ───────────────────────────────────────────────────────────────
async function callGroq(systemPrompt, userPrompt, maxTokens = 2048) {
  const completion = await groq.chat.completions.create({
    model: 'llama3-70b-8192',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    max_tokens: maxTokens,
    temperature: 0.7,
  });
  return completion.choices[0]?.message?.content ?? '';
}

// ── Safe JSON parsers ─────────────────────────────────────────────────────────
function parseJsonArray(text) {
  // Try direct parse first
  try {
    const parsed = JSON.parse(text);
    if (Array.isArray(parsed)) return parsed;
  } catch (_) {}

  // Extract array from text
  const match = text.match(/\[[\s\S]*\]/);
  if (!match) throw new Error('AI did not return a valid JSON array. Please try again.');
  return JSON.parse(match[0]);
}

function parseJsonObject(text) {
  try {
    const parsed = JSON.parse(text);
    if (typeof parsed === 'object' && !Array.isArray(parsed)) return parsed;
  } catch (_) {}

  const match = text.match(/\{[\s\S]*\}/);
  if (!match) throw new Error('AI did not return a valid JSON object. Please try again.');
  return JSON.parse(match[0]);
}

// ═════════════════════════════════════════════════════════════════════════════
//  GET / — Health check + wake-up endpoint
// ═════════════════════════════════════════════════════════════════════════════
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'PreparePro backend is running',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    firebase: firebaseInitialized ? 'connected' : 'not connected',
    groq: process.env.GROQ_API_KEY ? 'key set' : 'KEY MISSING - set GROQ_API_KEY env var',
  });
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateAptitude
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateAptitude', authenticate, async (req, res) => {
  const { topic = 'General Aptitude', count = 5 } = req.body;

  const systemPrompt =
    'You are an expert aptitude question generator for campus placement. ' +
    'Respond ONLY with a valid JSON array. No markdown, no code blocks, no explanation.';

  const userPrompt =
    `Generate ${count} unique aptitude questions on: "${topic}". ` +
    `Return ONLY a raw JSON array (no markdown, no \`\`\`json): ` +
    `[{"id":"1","question":"Q?","options":["A","B","C","D"],"correctIndex":0,"explanation":"Why A is correct","topic":"${topic}","difficulty":"Medium"}]`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt);
    const questions = parseJsonArray(raw);
    res.json({ questions });
  } catch (err) {
    console.error('generateAptitude error:', err.message);
    res.status(500).json({ error: err.message || 'Failed to generate questions.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateQuiz
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateQuiz', authenticate, async (req, res) => {
  const { subject = 'Java', subtopic = 'OOP', count = 10 } = req.body;

  const systemPrompt =
    'You are an expert technical quiz generator for campus placement. ' +
    'Respond ONLY with a valid JSON array. No markdown, no code blocks, no explanation.';

  const userPrompt =
    `Generate ${count} MCQ questions on ${subject} - ${subtopic}. ` +
    `Mix of easy/medium/hard. Return ONLY raw JSON array: ` +
    `[{"id":"1","question":"Q?","options":["A","B","C","D"],"correctIndex":0,"explanation":"Why correct","topic":"${subtopic}","difficulty":"Medium"}]`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt);
    const questions = parseJsonArray(raw);
    res.json({ questions });
  } catch (err) {
    console.error('generateQuiz error:', err.message);
    res.status(500).json({ error: err.message || 'Failed to generate quiz.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateInterview
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateInterview', authenticate, async (req, res) => {
  const { jobRole = 'Software Engineer', interviewType = 'Technical Round' } = req.body;

  const systemPrompt =
    'You are an expert interview coach for campus placements. ' +
    'Respond ONLY with a valid JSON array. No markdown, no code blocks, no explanation.';

  const userPrompt =
    `Generate 10 expected ${interviewType} questions for ${jobRole}. ` +
    `Return ONLY raw JSON array: ` +
    `[{"question":"Q?","answer":"Detailed answer","tip":"Pro tip","category":"${interviewType}"}]`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt, 3000);
    const questions = parseJsonArray(raw);
    res.json({ questions });
  } catch (err) {
    console.error('generateInterview error:', err.message);
    res.status(500).json({ error: err.message || 'Failed to generate interview questions.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateResume
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateResume', authenticate, async (req, res) => {
  const {
    name = '', email = '', phone = '', skills = '',
    education = '', experience = '', projects = '',
    targetRole = '', targetCompany = '', summary = '',
  } = req.body;

  const systemPrompt =
    'You are an expert resume writer for campus placements. ' +
    'Create ATS-optimized professional resumes in plain text format.';

  const userPrompt =
    `Create an ATS-optimized resume:\n` +
    `Name: ${name}\nEmail: ${email}\nPhone: ${phone}\n` +
    `Target Role: ${targetRole}\nTarget Company: ${targetCompany || 'General'}\n` +
    `Summary: ${summary || 'Generate a strong summary'}\n` +
    `Skills: ${skills}\nEducation: ${education}\n` +
    `Experience: ${experience || 'Fresher'}\nProjects: ${projects}\n\n` +
    `Write complete resume in plain text with sections: ` +
    `Contact Info, Professional Summary, Technical Skills, Education, ` +
    `Work Experience, Projects, Achievements.`;

  try {
    const resume = await callGroq(systemPrompt, userPrompt, 2500);
    res.json({ resume });
  } catch (err) {
    console.error('generateResume error:', err.message);
    res.status(500).json({ error: err.message || 'Failed to generate resume.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateCompany
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateCompany', authenticate, async (req, res) => {
  const { company = 'Google', role = 'Software Engineer' } = req.body;

  const systemPrompt =
    'You are an expert placement advisor. ' +
    'Respond ONLY with a valid JSON object. No markdown, no code blocks, no explanation.';

  const userPrompt =
    `Company placement guide for ${company} - ${role} role. ` +
    `Return ONLY raw JSON object: ` +
    `{"overview":"company overview","selectionProcess":"rounds description","faqs":"top 10 FAQs with answers","importantTopics":"key topics to study","tips":"tips to crack placement"}`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt, 3000);
    const data = parseJsonObject(raw);
    res.json(data);
  } catch (err) {
    console.error('generateCompany error:', err.message);
    res.status(500).json({ error: err.message || 'Failed to generate company guide.' });
  }
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Start ─────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`PreparePro backend running on port ${PORT}`);
  console.log(`GROQ_API_KEY: ${process.env.GROQ_API_KEY ? 'SET ✓' : 'MISSING ✗'}`);
});