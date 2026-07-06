// lib/services/sample_data_service.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/flashcard_model.dart';
import '../database/category_dao.dart';
import '../database/flashcard_dao.dart';
import '../database/database_helper.dart';

class SampleDataService {
  static final SampleDataService instance = SampleDataService._internal();
  SampleDataService._internal();

  final _uuid = const Uuid();

  /// Seed sample categories and flashcards on first run
  Future<void> seedIfFirstRun() async {
    final isFirst = await DatabaseHelper.instance.isFirstRun();
    if (!isFirst) return;

    await _seedCategories();
    await _seedFlashcards();
    await DatabaseHelper.instance.markSeeded();
  }

  Future<void> _seedCategories() async {
    final categories = [
      CategoryModel(
        id: 'cat_java',
        name: 'Java',
        iconCode: Icons.code.codePoint,
        colorHex: '#2563EB',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CategoryModel(
        id: 'cat_python',
        name: 'Python',
        iconCode: Icons.terminal.codePoint,
        colorHex: '#F59E0B',
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      CategoryModel(
        id: 'cat_dsa',
        name: 'Data Structures',
        iconCode: Icons.storage.codePoint,
        colorHex: '#10B981',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      CategoryModel(
        id: 'cat_dbms',
        name: 'DBMS',
        iconCode: Icons.table_chart.codePoint,
        colorHex: '#7C3AED',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      CategoryModel(
        id: 'cat_os',
        name: 'Operating System',
        iconCode: Icons.computer.codePoint,
        colorHex: '#DC2626',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      CategoryModel(
        id: 'cat_ai',
        name: 'AI & Machine Learning',
        iconCode: Icons.smart_toy.codePoint,
        colorHex: '#0891B2',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      CategoryModel(
        id: 'cat_math',
        name: 'Mathematics',
        iconCode: Icons.calculate.codePoint,
        colorHex: '#DB2777',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CategoryModel(
        id: 'cat_gk',
        name: 'General Knowledge',
        iconCode: Icons.public.codePoint,
        colorHex: '#65A30D',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    await CategoryDao.instance.insertAll(categories);
  }

  Future<void> _seedFlashcards() async {
    final now = DateTime.now();
    final cards = <FlashcardModel>[
      // Java
      _card('cat_java', 'What is JVM?',
          'Java Virtual Machine (JVM) is an abstract machine that provides a runtime environment to execute Java bytecode. It is platform-independent.',
          Difficulty.easy, ['java', 'basics'], now, 30),
      _card('cat_java', 'What is the difference between JDK, JRE, and JVM?',
          'JVM runs bytecode. JRE = JVM + libraries. JDK = JRE + development tools (compiler, debugger).',
          Difficulty.medium, ['java', 'basics'], now, 29),
      _card('cat_java', 'What is method overloading?',
          'Method overloading allows multiple methods in the same class with the same name but different parameters (number, type, or order).',
          Difficulty.easy, ['java', 'oops'], now, 28),
      _card('cat_java', 'What is the difference between == and .equals()?',
          '== compares object references. .equals() compares the actual content (values) of objects. For String comparisons, always use .equals().',
          Difficulty.medium, ['java', 'strings'], now, 27),
      _card('cat_java', 'What is a static keyword in Java?',
          'Static members belong to the class rather than instances. Static methods can be called without creating an object.',
          Difficulty.easy, ['java', 'oops'], now, 26),
      _card('cat_java', 'What is polymorphism?',
          'Polymorphism means "many forms." In Java, it allows objects of different classes to be treated as objects of a common superclass (via method overriding and overloading).',
          Difficulty.medium, ['java', 'oops'], now, 25),
      _card('cat_java', 'What is the difference between ArrayList and LinkedList?',
          'ArrayList uses a dynamic array (fast random access, O(1)). LinkedList uses doubly linked list (fast insertions/deletions, O(1)). ArrayList is better for read-heavy, LinkedList for write-heavy.',
          Difficulty.hard, ['java', 'collections'], now, 24),
      _card('cat_java', 'What is garbage collection in Java?',
          'Garbage collection is the automatic process of identifying and freeing unused objects from memory. JVM handles it via algorithms like Mark and Sweep.',
          Difficulty.medium, ['java', 'memory'], now, 23),
      _card('cat_java', 'What is an interface in Java?',
          'An interface is a contract that defines abstract methods. Classes that implement the interface must provide implementations for all its methods. Since Java 8, interfaces can have default and static methods.',
          Difficulty.medium, ['java', 'oops'], now, 22),
      _card('cat_java', 'What are Java Generics?',
          'Generics enable types (classes and interfaces) to be parameters when defining classes, interfaces, and methods. They provide compile-time type safety and eliminate the need for casting.',
          Difficulty.hard, ['java', 'generics'], now, 21),
      _card('cat_java', 'What is exception handling in Java?',
          'Exception handling uses try-catch-finally blocks to manage runtime errors. Checked exceptions must be declared or handled; unchecked exceptions (RuntimeException) do not.',
          Difficulty.medium, ['java', 'exceptions'], now, 20),
      _card('cat_java', 'What is the Collections Framework?',
          'A unified architecture for storing and manipulating groups of objects. Core interfaces: List, Set, Map, Queue. Key implementations: ArrayList, HashMap, HashSet, LinkedList.',
          Difficulty.hard, ['java', 'collections'], now, 19),

      // Python
      _card('cat_python', 'What is Python?',
          'Python is a high-level, interpreted, dynamically-typed programming language known for its simplicity and readability. Created by Guido van Rossum in 1991.',
          Difficulty.easy, ['python', 'basics'], now, 18),
      _card('cat_python', 'What is a list comprehension?',
          'A concise way to create lists: [expression for item in iterable if condition]. Example: squares = [x**2 for x in range(10)]',
          Difficulty.medium, ['python', 'lists'], now, 17),
      _card('cat_python', 'What is a decorator in Python?',
          'A decorator is a function that takes another function and extends its behavior without modifying it. Uses the @symbol. Common for logging, timing, authentication.',
          Difficulty.hard, ['python', 'advanced'], now, 16),
      _card('cat_python', 'Difference between tuple and list?',
          'Lists are mutable (can be changed), tuples are immutable (cannot be changed after creation). Tuples are faster and used as dictionary keys.',
          Difficulty.easy, ['python', 'basics'], now, 15),
      _card('cat_python', 'What is a lambda function?',
          'An anonymous single-expression function: lambda arguments: expression. Example: double = lambda x: x * 2. Useful for short functions passed as arguments.',
          Difficulty.medium, ['python', 'functions'], now, 14),
      _card('cat_python', 'What is GIL in Python?',
          'Global Interpreter Lock (GIL) is a mutex that allows only one thread to execute Python bytecode at a time, limiting true multi-threading. Use multiprocessing module for CPU-bound tasks.',
          Difficulty.hard, ['python', 'advanced', 'threading'], now, 13),
      _card('cat_python', 'What are *args and **kwargs?',
          '*args passes a variable number of positional arguments as a tuple. **kwargs passes a variable number of keyword arguments as a dictionary.',
          Difficulty.medium, ['python', 'functions'], now, 12),
      _card('cat_python', 'What is the difference between deep copy and shallow copy?',
          'Shallow copy creates a new object but references the same nested objects. Deep copy creates a new object AND recursively copies all nested objects. Use copy.deepcopy().',
          Difficulty.hard, ['python', 'advanced'], now, 11),

      // Data Structures
      _card('cat_dsa', 'What is a stack?',
          'A stack is a LIFO (Last In First Out) data structure. Operations: push (add), pop (remove from top), peek (view top). Used in function calls, undo operations.',
          Difficulty.easy, ['dsa', 'stack'], now, 10),
      _card('cat_dsa', 'What is a queue?',
          'A queue is a FIFO (First In First Out) data structure. Operations: enqueue (add to rear), dequeue (remove from front). Used in BFS, print spoolers.',
          Difficulty.easy, ['dsa', 'queue'], now, 9),
      _card('cat_dsa', 'What is a binary search tree?',
          'A BST is a binary tree where left child < parent < right child. Average case: O(log n) for search/insert/delete. Worst case (skewed): O(n).',
          Difficulty.medium, ['dsa', 'trees'], now, 8),
      _card('cat_dsa', 'What is Big O notation?',
          'Big O notation describes the upper bound of algorithm complexity in terms of input size n. Examples: O(1) constant, O(log n) logarithmic, O(n) linear, O(n²) quadratic.',
          Difficulty.medium, ['dsa', 'complexity'], now, 7),
      _card('cat_dsa', 'What is a hash table?',
          'A hash table stores key-value pairs using a hash function to compute an index into an array. Average O(1) for search, insert, delete. Collisions handled via chaining or open addressing.',
          Difficulty.medium, ['dsa', 'hashing'], now, 6),
      _card('cat_dsa', 'Difference between DFS and BFS?',
          'DFS (Depth First Search) explores as far as possible before backtracking, uses a stack. BFS (Breadth First Search) explores level by level, uses a queue. BFS finds shortest path in unweighted graphs.',
          Difficulty.hard, ['dsa', 'graphs'], now, 5),
      _card('cat_dsa', 'What is dynamic programming?',
          'DP is an optimization technique that solves problems by breaking them into overlapping subproblems and storing results (memoization/tabulation) to avoid redundant computation.',
          Difficulty.hard, ['dsa', 'algorithms'], now, 4),

      // DBMS
      _card('cat_dbms', 'What is normalization?',
          'Normalization organizes database columns and tables to reduce redundancy. 1NF: atomic values. 2NF: no partial dependency. 3NF: no transitive dependency. BCNF: every determinant is a candidate key.',
          Difficulty.hard, ['dbms', 'normalization'], now, 3),
      _card('cat_dbms', 'What is a primary key?',
          'A primary key uniquely identifies each record in a table. It cannot be NULL and must be unique. A table can have only one primary key (single or composite).',
          Difficulty.easy, ['dbms', 'keys'], now, 2),
      _card('cat_dbms', 'What is ACID in databases?',
          'ACID = Atomicity (all or nothing), Consistency (data remains valid), Isolation (transactions independent), Durability (committed data persists). Properties of reliable transactions.',
          Difficulty.medium, ['dbms', 'transactions'], now, 1),
      _card('cat_dbms', 'What is the difference between SQL and NoSQL?',
          'SQL: relational, table-based, fixed schema, uses SQL language. NoSQL: non-relational, document/key-value/graph/column, flexible schema. SQL for complex queries; NoSQL for scalability.',
          Difficulty.medium, ['dbms', 'nosql'], now, 0),

      // OS
      _card('cat_os', 'What is a process vs. thread?',
          'A process is an independent program in execution with its own memory. A thread is a lightweight unit within a process sharing the same memory. Threads have lower overhead.',
          Difficulty.medium, ['os', 'processes'], now, 0),
      _card('cat_os', 'What is deadlock?',
          'Deadlock occurs when two or more processes are waiting for each other to release resources. Conditions: Mutual Exclusion, Hold and Wait, No Preemption, Circular Wait.',
          Difficulty.hard, ['os', 'deadlock'], now, 0),
      _card('cat_os', 'What is virtual memory?',
          'Virtual memory extends physical RAM by using disk storage. It allows programs larger than RAM to run by swapping pages in/out (paging). Managed by the MMU.',
          Difficulty.hard, ['os', 'memory'], now, 0),
      _card('cat_os', 'What is context switching?',
          'Context switching is the process of saving the state of a running process/thread and loading the saved state of another. Enables multitasking but has overhead.',
          Difficulty.medium, ['os', 'scheduling'], now, 0),

      // AI & ML
      _card('cat_ai', 'What is machine learning?',
          'Machine learning is a subset of AI where algorithms learn patterns from data to make predictions or decisions without being explicitly programmed.',
          Difficulty.easy, ['ai', 'basics'], now, 0),
      _card('cat_ai', 'What is supervised vs unsupervised learning?',
          'Supervised: learns from labeled data (classification, regression). Unsupervised: finds patterns in unlabeled data (clustering, dimensionality reduction).',
          Difficulty.medium, ['ai', 'ml'], now, 0),
      _card('cat_ai', 'What is overfitting?',
          'Overfitting occurs when a model learns training data too well, including noise, and performs poorly on new data. Prevented by: regularization, dropout, more data, cross-validation.',
          Difficulty.hard, ['ai', 'ml', 'bias-variance'], now, 0),
      _card('cat_ai', 'What is a neural network?',
          'A neural network is a computational model inspired by the brain, consisting of layers of interconnected nodes (neurons). Deep neural networks have many hidden layers.',
          Difficulty.medium, ['ai', 'deep-learning'], now, 0),

      // Math
      _card('cat_math', 'What is a derivative?',
          'A derivative measures the rate of change of a function with respect to a variable. f\'(x) = lim(h→0) [f(x+h) - f(x)] / h. Geometrically, it is the slope of the tangent line.',
          Difficulty.medium, ['math', 'calculus'], now, 0),
      _card('cat_math', 'What is the Pythagorean theorem?',
          'In a right triangle, the square of the hypotenuse equals the sum of squares of the other two sides: a² + b² = c².',
          Difficulty.easy, ['math', 'geometry'], now, 0),
      _card('cat_math', 'What is a matrix?',
          'A matrix is a rectangular array of numbers arranged in rows and columns. Used in linear algebra, computer graphics, ML. Operations: addition, multiplication, transposition, inversion.',
          Difficulty.medium, ['math', 'linear-algebra'], now, 0),

      // General Knowledge
      _card('cat_gk', 'What is the speed of light?',
          'The speed of light in vacuum is approximately 299,792,458 meters per second (about 3 × 10⁸ m/s or 186,000 miles per second).',
          Difficulty.easy, ['gk', 'physics'], now, 0),
      _card('cat_gk', 'What is DNA?',
          'DNA (Deoxyribonucleic Acid) is the molecule that carries genetic information in living organisms. It has a double helix structure made of nucleotides (A, T, G, C).',
          Difficulty.medium, ['gk', 'biology'], now, 0),
      _card('cat_gk', 'Who invented the World Wide Web?',
          'Tim Berners-Lee invented the World Wide Web in 1989 while working at CERN. He proposed a system of hypertext documents accessible via the Internet.',
          Difficulty.easy, ['gk', 'technology'], now, 0),
    ];

    await FlashcardDao.instance.insertAll(cards);
  }

  FlashcardModel _card(
    String categoryId,
    String question,
    String answer,
    Difficulty difficulty,
    List<String> tags,
    DateTime base,
    int daysAgo,
  ) {
    final dt = base.subtract(Duration(days: daysAgo));
    return FlashcardModel(
      id: _uuid.v4(),
      question: question,
      answer: answer,
      categoryId: categoryId,
      difficulty: difficulty,
      tags: tags,
      isFavorite: false,
      createdAt: dt,
      updatedAt: dt,
    );
  }
}
