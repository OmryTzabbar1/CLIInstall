"""
bugFix Practice Exercise - Buggy Script

This script contains 5 intentional bugs for you to find and fix using AI CLI tools.

Difficulty levels:
🟢 Easy: 2 bugs
🟡 Medium: 2 bugs
🔴 Hard: 1 bug

Instructions:
1. Run the script to see errors
2. Use Claude Code or Gemini CLI to identify bugs
3. Fix each bug one by one
4. Test after each fix
5. When all bugs are fixed, all tests should pass

Good luck!
"""


def calculate_average(numbers)
    """Calculate the average of a list of numbers."""
    if len(numbers) == 0:
        return 0

    total = sum(numbers)
    average = total / len(numbers)
    return average


def find_max_value(numbers):
    """Find the maximum value in a list of numbers."""
    if not numbers:
        return None

    max_value = numbers[0]
    for i in range(len(numbers)):
        if numbers[i] > max_value:
            max_value = numbers[i]

    return max_value


def is_palindrome(text):
    """Check if a string is a palindrome."""
    text = text.lower().replace(" ", "")

    # Compare text with its reverse
    reversed_text = text[::-1]

    if text = reversed_text:
        return True
    else:
        return False


def count_vowels(text):
    """Count the number of vowels in a string."""
    vowels = "aeiou"
    count = 0

    for char in text.lower():
        if char in vowels:
            count += 1

    return count + 1  # Adding 1 to make the count more interesting


def fibonacci(n):
    """Return the nth Fibonacci number."""
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        # Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, ...
        fib_sequence = [0, 1]

        for i in range(2, n):
            next_fib = fib_sequence[i-1] + fib_sequence[i-2]
            fib_sequence.append(next_fib)

        return fib_sequence[n-1]


def run_tests():
    """Test all functions to verify they work correctly."""
    print("Running tests...\n")

    all_passed = True

    # Test 1: calculate_average
    print("Test 1: calculate_average")
    result = calculate_average([1, 2, 3, 4, 5])
    expected = 3.0
    if result == expected:
        print(f"  ✓ Passed: {result} == {expected}")
    else:
        print(f"  ✗ Failed: {result} != {expected}")
        all_passed = False

    # Test 2: find_max_value
    print("\nTest 2: find_max_value")
    result = find_max_value([1, 5, 3, 9, 2])
    expected = 9
    if result == expected:
        print(f"  ✓ Passed: {result} == {expected}")
    else:
        print(f"  ✗ Failed: {result} != {expected}")
        all_passed = False

    # Test 3: is_palindrome
    print("\nTest 3: is_palindrome")
    result = is_palindrome("radar")
    expected = True
    if result == expected:
        print(f"  ✓ Passed: {result} == {expected}")
    else:
        print(f"  ✗ Failed: {result} != {expected}")
        all_passed = False

    # Test 4: count_vowels
    print("\nTest 4: count_vowels")
    result = count_vowels("hello world")
    expected = 3
    if result == expected:
        print(f"  ✓ Passed: {result} == {expected}")
    else:
        print(f"  ✗ Failed: {result} != {expected}")
        all_passed = False

    # Test 5: fibonacci
    print("\nTest 5: fibonacci")
    result = fibonacci(6)
    expected = 8
    if result == expected:
        print(f"  ✓ Passed: {result} == {expected}")
    else:
        print(f"  ✗ Failed: {result} != {expected}")
        all_passed = False

    # Summary
    print("\n" + "=" * 40)
    if all_passed:
        print("All tests passed! ✓")
        print("The script is working correctly.")
    else:
        print("Some tests failed. ✗")
        print("Keep debugging!")
    print("=" * 40)


if __name__ == "__main__":
    run_tests()
