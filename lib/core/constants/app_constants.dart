class AppConstants {
  // ── Backend URL ─────────────────────────────────────────────────────────────
  // Replace with your actual Render URL after deploying
  // Example: 'https://preparepro-backend.onrender.com'
  // DO NOT add trailing slash
  static const String backendBaseUrl =
      'https://preparepro.onrender.com';

  // ── API Endpoints ────────────────────────────────────────────────────────────
  static const String generateAptitudeEndpoint  = '/generateAptitude';
  static const String generateQuizEndpoint      = '/generateQuiz';
  static const String generateInterviewEndpoint = '/generateInterview';
  static const String generateResumeEndpoint    = '/generateResume';
  static const String generateCompanyEndpoint   = '/generateCompany';

  // ── Hive Box Names ───────────────────────────────────────────────────────────
  static const String cacheBox     = 'cache';
  static const String bookmarksBox = 'bookmarks';

  // ── Quiz Timer ───────────────────────────────────────────────────────────────
  static const int quizTimerSeconds      = 45;
  static const int questionsPerSession   = 10;

  // ── Subjects ─────────────────────────────────────────────────────────────────
  static const List<String> subjects = [
    'Java', 'Python', 'C++', 'DBMS', 'Operating System',
    'Computer Networks', 'Data Structures', 'Algorithms',
    'Web Development', 'Machine Learning', 'System Design', 'SQL',
  ];

  static const Map<String, List<String>> subtopics = {
    'Java':             ['OOP Concepts', 'JDBC', 'Collections', 'Multithreading', 'Spring Boot', 'Java 8 Features'],
    'Python':           ['OOP', 'Libraries', 'Django', 'Flask', 'Data Structures', 'Decorators'],
    'C++':              ['Pointers', 'STL', 'OOP', 'Memory Management', 'Templates'],
    'DBMS':             ['SQL', 'Normalization', 'Transactions', 'Indexing', 'ER Model'],
    'Operating System': ['Process Management', 'Memory Management', 'File Systems', 'Scheduling', 'Deadlocks'],
    'Computer Networks':['OSI Model', 'TCP/IP', 'HTTP/HTTPS', 'DNS', 'Routing'],
    'Data Structures':  ['Arrays', 'Linked Lists', 'Trees', 'Graphs', 'Hashing'],
    'Algorithms':       ['Sorting', 'Searching', 'Dynamic Programming', 'Greedy', 'Divide and Conquer'],
    'Web Development':  ['HTML/CSS', 'JavaScript', 'React', 'REST APIs', 'Node.js'],
    'Machine Learning': ['Supervised Learning', 'Neural Networks', 'Feature Engineering', 'Model Evaluation'],
    'System Design':    ['Scalability', 'Load Balancing', 'Caching', 'Databases', 'Microservices'],
    'SQL':              ['Joins', 'Aggregate Functions', 'Subqueries', 'Indexes', 'Stored Procedures'],
  };

  // ── Companies ────────────────────────────────────────────────────────────────
  static const List<String> topCompanies = [
    'Google', 'Microsoft', 'Amazon', 'Meta', 'Apple',
    'Infosys', 'TCS', 'Wipro', 'Accenture', 'Cognizant',
    'Deloitte', 'IBM', 'Oracle', 'Salesforce', 'Adobe',
    'Flipkart', 'Paytm', 'Razorpay', 'CRED', 'Zomato',
    'Swiggy', 'Ola', 'Meesho', 'PhonePe', 'Zepto',
  ];

  // ── Interview Types ──────────────────────────────────────────────────────────
  static const List<String> interviewTypes = [
    'HR Round', 'Technical Round', 'Managerial Round',
    'System Design', 'Aptitude Test',
  ];
}