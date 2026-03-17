require('dotenv').config();
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const Groq = require('groq-sdk');

// ── Firebase Admin (for verifying Flutter user tokens) ───────────────────────
// serviceAccountKey.json is downloaded from Firebase Console
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(cors({ origin: '*' }));
app.use(express.json());

// ── Auth Middleware ───────────────────────────────────────────────────────────
const authenticate = async (req, res, next) => {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  try {
    req.user = await admin.auth().verifyIdToken(token);
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// ── Groq Client ───────────────────────────────────────────────────────────────
// GROQ_API_KEY is set in Render dashboard environment variables - never hardcoded
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// ── Helper: Call Groq ─────────────────────────────────────────────────────────
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

// ── Parse JSON safely ─────────────────────────────────────────────────────────
function parseJsonSafe(text) {
  const match = text.match(/\[[\s\S]*\]/);
  if (!match) throw new Error('Invalid JSON response from AI');
  return JSON.parse(match[0]);
}

function parseObjectSafe(text) {
  const match = text.match(/\{[\s\S]*\}/);
  if (!match) throw new Error('Invalid JSON response from AI');
  return JSON.parse(match[0]);
}

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateAptitude
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateAptitude', authenticate, async (req, res) => {
  const { topic = 'General Aptitude', count = 5 } = req.body;

  const systemPrompt = `You are an expert aptitude question generator for campus placement preparation.
Always respond ONLY with a valid JSON array. No markdown, no explanation.`;

  const userPrompt = `Generate ${count} unique aptitude questions on the topic: "${topic}".
Return ONLY a JSON array with this exact structure:
[
  {
    "id": "unique_string",
    "question": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "explanation": "Brief explanation of the correct answer",
    "topic": "${topic}",
    "difficulty": "Medium"
  }
]`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt);
    const questions = parseJsonSafe(raw);
    res.json({ questions });
  } catch (err) {
    console.error('generateAptitude error:', err);
    res.status(500).json({ error: 'Failed to generate questions. Try again.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateQuiz
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateQuiz', authenticate, async (req, res) => {
  const { subject = 'Java', subtopic = 'OOP', count = 10 } = req.body;

  const systemPrompt = `You are an expert technical quiz generator for campus placement preparation.
Always respond ONLY with a valid JSON array. No markdown, no explanation.`;

  const userPrompt = `Generate ${count} multiple-choice technical questions on ${subject} - ${subtopic}.
Include a mix of easy, medium, and hard questions. Make questions unique and not repeated.
Return ONLY a JSON array:
[
  {
    "id": "unique_string",
    "question": "Question text?",
    "options": ["A", "B", "C", "D"],
    "correctIndex": 2,
    "explanation": "Why this answer is correct",
    "topic": "${subtopic}",
    "difficulty": "Medium"
  }
]`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt);
    const questions = parseJsonSafe(raw);
    res.json({ questions });
  } catch (err) {
    console.error('generateQuiz error:', err);
    res.status(500).json({ error: 'Failed to generate quiz. Try again.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateInterview
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateInterview', authenticate, async (req, res) => {
  const { jobRole = 'Software Engineer', interviewType = 'Technical Round' } = req.body;

  const systemPrompt = `You are an expert interview coach for campus placements.
Always respond ONLY with a valid JSON array. No markdown, no explanation.`;

  const userPrompt = `Generate 10 most expected ${interviewType} interview questions for a ${jobRole} role.
Return ONLY a JSON array:
[
  {
    "question": "Tell me about yourself.",
    "answer": "Detailed model answer here...",
    "tip": "Pro tip for answering this question",
    "category": "${interviewType}"
  }
]`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt, 3000);
    const questions = parseJsonSafe(raw);
    res.json({ questions });
  } catch (err) {
    console.error('generateInterview error:', err);
    res.status(500).json({ error: 'Failed to generate interview questions. Try again.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateResume
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateResume', authenticate, async (req, res) => {
  const {
    name, email, phone, skills, education, experience,
    projects, targetRole, targetCompany, summary
  } = req.body;

  const systemPrompt = `You are an expert resume writer specializing in ATS-optimized resumes for campus placements.
Create professional, impactful resumes in clean text format.`;

  const userPrompt = `Create an ATS-optimized resume for:
Name: ${name}
Email: ${email}
Phone: ${phone || 'Not provided'}
Target Role: ${targetRole}
Target Company: ${targetCompany || 'General'}
Professional Summary: ${summary || 'Generate a professional summary'}
Skills: ${skills}
Education: ${education}
Work Experience: ${experience || 'Fresher'}
Projects: ${projects}

Requirements:
- ATS-friendly format with proper keywords for ${targetRole}
- Use action verbs and quantifiable achievements
- Include relevant skills for ${targetRole}
- Professional and concise language
- Standard resume sections: Contact, Summary, Skills, Education, Experience, Projects

Return the complete resume as plain text.`;

  try {
    const resume = await callGroq(systemPrompt, userPrompt, 2500);
    res.json({ resume });
  } catch (err) {
    console.error('generateResume error:', err);
    res.status(500).json({ error: 'Failed to generate resume. Try again.' });
  }
});

// ═════════════════════════════════════════════════════════════════════════════
//  POST /generateCompany
// ═════════════════════════════════════════════════════════════════════════════
app.post('/generateCompany', authenticate, async (req, res) => {
  const { company = 'Google', role = 'Software Engineer' } = req.body;

  const systemPrompt = `You are an expert campus placement advisor with deep knowledge of company hiring processes.
Always respond ONLY with a valid JSON object. No markdown, no explanation.`;

  const userPrompt = `Generate a comprehensive placement preparation guide for ${company} for a ${role} position.
Return ONLY a JSON object:
{
  "overview": "Brief company overview, culture, values, and what they look for",
  "selectionProcess": "Step-by-step selection process: rounds, format, duration",
  "faqs": "10 most frequently asked questions at ${company} with brief answers",
  "importantTopics": "Most important technical and non-technical topics to prepare",
  "tips": "5-7 specific tips to crack ${company} placement for ${role}"
}`;

  try {
    const raw = await callGroq(systemPrompt, userPrompt, 3000);
    const data = parseObjectSafe(raw);
    res.json(data);
  } catch (err) {
    console.error('generateCompany error:', err);
    res.status(500).json({ error: 'Failed to generate company guide. Try again.' });
  }
});

// ── Health check ─────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({ status: 'PreparePro backend running', version: '1.0.0' });
});

// ── Start server ──────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`PreparePro backend running on port ${PORT}`);
});