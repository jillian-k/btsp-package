## Agent Rules

1. Only use the charitynavdev org for this project - do not use any other instances
2. always use the sf cli to interact with the org
   2.a always deploy and check changes against our target org
3. Always look in the code base before writing new functionality - we do not want duplicative code
4. Always check for upstream consumers of interfaces or downstream producing that may be broken with a refactor - especially when crossing boundaries of MVC
5. Create test classes for full coverage of all apex code written - 90% test coverage minimum
   5a. Always use TestDataFactory for DML and SOQL test behavior and functionality - check first before writing new data interfaces for unit tests
6. When starting new work or feature, please create a new branch. Use git often, commiting changes along the way.
7. Do not issue any PRs in GIT until I tell you to