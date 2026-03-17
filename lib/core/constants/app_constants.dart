class AppConstants {
  // Backend URL – replace with your deployed Firebase Functions / Node.js URL
  static const String backendBaseUrl =
      'https://YOUR_FIREBASE_PROJECT_REGION-YOUR_PROJECT_ID.cloudfunctions.net';

  // Endpoints
  static const String generateQuizEndpoint = '/generateQuiz';
  static const String generateInterviewEndpoint = '/generateInterview';
  static const String generateResumeEndpoint = '/generateResume';
  static const String generateAptitudeEndpoint = '/generateAptitude';
  static const String generateCompanyEndpoint = '/generateCompany';

  // Hive box names
  static const String cacheBox = 'cache';
  static const String bookmarksBox = 'bookmarks';

  // Subjects for Technical Quiz
  static const List<String> subjects = [
    'Java',
    'Python',
    'C++',
    'DBMS',
    'Operating System',
    'Computer Networks',
    'Data Structures',
    'Algorithms',
    'Web Development',
    'Machine Learning',
    'System Design',
    'SQL',
  ];

  // Java subtopics
  static const Map<String, List<String>> subtopics = {
    'Java': ['OOP Concepts', 'JDBC', 'Collections', 'Multithreading', 'Spring Boot', 'Java 8 Features'],
    'Python': ['OOP', 'Libraries', 'Django', 'Flask', 'Data Structures', 'Decorators'],
    'C++': ['Pointers', 'STL', 'OOP', 'Memory Management', 'Templates'],
    'DBMS': ['SQL', 'Normalization', 'Transactions', 'Indexing', 'ER Model'],
    'Operating System': ['Process Management', 'Memory Management', 'File Systems', 'Scheduling', 'Deadlocks'],
    'Computer Networks': ['OSI Model', 'TCP/IP', 'HTTP/HTTPS', 'DNS', 'Routing'],
    'Data Structures': ['Arrays', 'Linked Lists', 'Trees', 'Graphs', 'Hashing'],
    'Algorithms': ['Sorting', 'Searching', 'Dynamic Programming', 'Greedy', 'Divide and Conquer'],
    'Web Development': ['HTML/CSS', 'JavaScript', 'React', 'REST APIs', 'Node.js'],
    'Machine Learning': ['Supervised Learning', 'Neural Networks', 'Feature Engineering', 'Model Evaluation'],
    'System Design': ['Scalability', 'Load Balancing', 'Caching', 'Databases', 'Microservices'],
    'SQL': ['Joins', 'Aggregate Functions', 'Subqueries', 'Indexes', 'Stored Procedures'],
  };

  // Companies for Company Prep
  static const List<String> topCompanies = [
    'Google', 'Microsoft', 'Amazon', 'Meta', 'Apple',
    'Infosys', 'TCS', 'Wipro', 'Accenture', 'Cognizant',
    'Deloitte', 'IBM', 'Oracle', 'Salesforce', 'Adobe',
    'Flipkart', 'Paytm', 'Razorpay', 'CRED', 'Zomato',
    'Swiggy', 'Ola', 'Meesho', 'PhonePe', 'Zepto',
  ];

  // Interview Types
  static const List<String> interviewTypes = [
    'HR Round',
    'Technical Round',
    'Managerial Round',
    'System Design',
    'Aptitude Test',
  ];

  // Timer
  static const int quizTimerSeconds = 45;
  static const int questionsPerSession = 10;
}