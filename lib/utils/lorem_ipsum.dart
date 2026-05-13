class LoremIpsum {
  static const String _words = 'lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum';
  
  static String generate(int wordCount) {
    final List<String> wordList = _words.split(' ');
    String result = '';
    
    for (int i = 0; i < wordCount; i++) {
      result += wordList[i % wordList.length];
      if (i < wordCount - 1) result += ' ';
    }
    
    return result;
  }
  
  static String generateWords(int count) => generate(count);
  
  static String generateSentences(int sentenceCount) {
    String result = '';
    for (int i = 0; i < sentenceCount; i++) {
      int wordsInSentence = 8 + (i % 7); // 8-14 words per sentence
      result += generate(wordsInSentence);
      result += '. ';
      if (i < sentenceCount - 1) {
        result = result[0].toUpperCase() + result.substring(1);
      }
    }
    return result[0].toUpperCase() + result.substring(1);
  }
}
