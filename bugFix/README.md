# bugFix Practice Exercise

## Overview

Welcome to the **bugFix** practice exercise! This is a hands-on opportunity to learn how to use AI CLI tools (Claude Code and Gemini CLI) to debug Python code.

## What You'll Learn

- How to use Claude Code and Gemini CLI for debugging
- Common Python bug patterns and how to fix them
- Effective prompting techniques for AI-assisted debugging
- Testing and verification workflows

## The Challenge

The file `buggy_script.py` contains **5 intentional bugs** of varying difficulty. Your mission is to:

1. **Find the bugs** using AI CLI tools
2. **Understand why** they're bugs
3. **Fix them** with AI assistance
4. **Verify** your fixes work correctly

## Bug Difficulty Levels

- **🟢 Easy** (2 bugs): Syntax errors, typos, obvious mistakes
- **🟡 Medium** (2 bugs): Logic errors, off-by-one errors, type issues
- **🔴 Hard** (1 bug): Algorithmic flaws, subtle edge cases

## Getting Started

### Step 1: Examine the Buggy Script

```bash
cat buggy_script.py
```

Try running it to see what errors appear:

```bash
python3 buggy_script.py
```

### Step 2: Use AI Tools to Debug

#### Using Claude Code

```bash
# Start Claude Code in this directory
npx @anthropic-ai/claude-code

# Or use the alias
claude
```

**Example prompts to try:**

- "Analyze buggy_script.py and identify all bugs"
- "What's wrong with the calculate_average function?"
- "Fix the syntax error on line X"
- "Why does this function return the wrong result?"
- "Run the script and explain the error"

#### Using Gemini CLI

```bash
# If Gemini CLI is installed
gemini "Analyze buggy_script.py for bugs"
```

### Step 3: Fix the Bugs

As you identify bugs, fix them one by one. You can:

1. **Edit manually** based on AI suggestions
2. **Ask AI to provide fixed code** and copy it
3. **Use AI to explain** the fix before implementing

### Step 4: Test Your Fixes

After each fix, run the script again:

```bash
python3 buggy_script.py
```

When all bugs are fixed, you should see:

```
All tests passed! ✓
The script is working correctly.
```

### Step 5: Run Unit Tests (Optional)

If you've installed pytest:

```bash
pytest tests/
```

## Tips for Success

### Effective AI Prompting

**❌ Too vague:**
- "Fix my code"
- "This doesn't work"

**✅ Specific and clear:**
- "Explain the error on line 15"
- "Why does calculate_average return incorrect results?"
- "What's the off-by-one error in the loop?"

### Debugging Strategy

1. **Start with syntax errors** - These prevent the script from running
2. **Then runtime errors** - These cause crashes during execution
3. **Finally logic errors** - These produce wrong results

### Learning Approach

Don't just copy-paste fixes! For each bug:

1. **Understand why it's wrong**
2. **Learn the correct pattern**
3. **Test your understanding** by explaining it in your own words

## What Each Function Should Do

### `calculate_average(numbers)`
- Input: List of numbers
- Output: Average of those numbers
- Example: `[1, 2, 3, 4, 5]` → `3.0`

### `find_max_value(numbers)`
- Input: List of numbers
- Output: Maximum value in the list
- Example: `[1, 5, 3, 9, 2]` → `9`

### `is_palindrome(text)`
- Input: String
- Output: `True` if palindrome, `False` otherwise
- Example: `"radar"` → `True`, `"hello"` → `False`

### `count_vowels(text)`
- Input: String
- Output: Number of vowels (a, e, i, o, u)
- Example: `"hello world"` → `3`

### `fibonacci(n)`
- Input: Integer n
- Output: The nth Fibonacci number
- Example: `fibonacci(6)` → `8` (sequence: 0, 1, 1, 2, 3, 5, 8)

## Checking Your Work

Once you think you've fixed all bugs, compare your solution with `SOLUTION.md`. This file contains:

- Explanation of each bug
- Why it was a bug
- The correct fix
- What you should have learned

**⚠️ Try to solve on your own first!** Looking at solutions too early defeats the learning purpose.

## Getting Stuck?

If you're stuck on a bug:

1. **Read the error message carefully** - It often tells you exactly what's wrong
2. **Try different AI prompts** - Rephrase your question
3. **Break down the problem** - Focus on one function at a time
4. **Ask AI to explain concepts** - "What is a palindrome?", "How do Fibonacci numbers work?"
5. **Check SOLUTION.md for hints** - But try on your own first!

## Success Criteria

You've successfully completed the exercise when:

- ✅ The script runs without errors
- ✅ All function tests pass
- ✅ You understand why each bug was wrong
- ✅ You can explain the correct approach

## Next Steps

After completing this exercise:

1. **Try modifying the functions** - Add new features
2. **Create your own buggy script** - Practice debugging from scratch
3. **Use AI tools for real projects** - Apply what you've learned
4. **Explore advanced AI features** - Code generation, refactoring, optimization

## Resources

- **Claude Code Documentation**: https://docs.claude.com/en/docs/claude-code
- **Gemini CLI Documentation**: https://ai.google.dev/
- **Python Documentation**: https://docs.python.org/3/
- **Debugging Tips**: See `../docs/TROUBLESHOOTING.md`

## Questions or Issues?

If you encounter problems with the exercise itself (not the intentional bugs!):

- Check that your Python version is 3.9+: `python3 --version`
- Ensure UV is installed: `uv --version`
- Review the installation logs
- See `../docs/TROUBLESHOOTING.md`

---

**Good luck, and happy debugging!** 🐛🔨

Remember: The goal isn't just to fix the bugs, but to learn how to use AI tools effectively for debugging. Take your time and experiment with different approaches!
