"""
Unit tests for the fixed buggy_script.py

These tests verify that all functions work correctly after fixing the bugs.

Run with:
    pytest tests/
    pytest tests/test_fixed_script.py
    pytest tests/test_fixed_script.py -v
"""

import sys
from pathlib import Path

# Add parent directory to path to import buggy_script
sys.path.insert(0, str(Path(__file__).parent.parent))

import buggy_script


class TestCalculateAverage:
    """Tests for calculate_average function"""

    def test_normal_list(self):
        """Test with a normal list of numbers"""
        assert buggy_script.calculate_average([1, 2, 3, 4, 5]) == 3.0

    def test_empty_list(self):
        """Test with an empty list"""
        assert buggy_script.calculate_average([]) == 0

    def test_single_element(self):
        """Test with a single element"""
        assert buggy_script.calculate_average([5]) == 5.0

    def test_negative_numbers(self):
        """Test with negative numbers"""
        assert buggy_script.calculate_average([-1, -2, -3, -4, -5]) == -3.0

    def test_mixed_numbers(self):
        """Test with mixed positive and negative numbers"""
        assert buggy_script.calculate_average([- 10, 0, 10]) == 0.0

    def test_floats(self):
        """Test with floating point numbers"""
        result = buggy_script.calculate_average([1.5, 2.5, 3.5])
        assert abs(result - 2.5) < 0.001


class TestFindMaxValue:
    """Tests for find_max_value function"""

    def test_normal_list(self):
        """Test with a normal list"""
        assert buggy_script.find_max_value([1, 5, 3, 9, 2]) == 9

    def test_empty_list(self):
        """Test with an empty list"""
        assert buggy_script.find_max_value([]) is None

    def test_single_element(self):
        """Test with a single element"""
        assert buggy_script.find_max_value([42]) == 42

    def test_negative_numbers(self):
        """Test with all negative numbers"""
        assert buggy_script.find_max_value([-5, -2, -10, -1]) == -1

    def test_duplicates(self):
        """Test with duplicate max values"""
        assert buggy_script.find_max_value([3, 5, 5, 2, 5, 1]) == 5

    def test_first_is_max(self):
        """Test when first element is the maximum"""
        assert buggy_script.find_max_value([10, 5, 3, 1]) == 10

    def test_last_is_max(self):
        """Test when last element is the maximum"""
        assert buggy_script.find_max_value([1, 3, 5, 10]) == 10


class TestIsPalindrome:
    """Tests for is_palindrome function"""

    def test_simple_palindrome(self):
        """Test with a simple palindrome"""
        assert buggy_script.is_palindrome("radar") is True

    def test_not_palindrome(self):
        """Test with a non-palindrome"""
        assert buggy_script.is_palindrome("hello") is False

    def test_single_character(self):
        """Test with a single character"""
        assert buggy_script.is_palindrome("a") is True

    def test_empty_string(self):
        """Test with an empty string"""
        assert buggy_script.is_palindrome("") is True

    def test_palindrome_with_spaces(self):
        """Test palindrome with spaces"""
        assert buggy_script.is_palindrome("race car") is True

    def test_mixed_case_palindrome(self):
        """Test with mixed case"""
        assert buggy_script.is_palindrome("RaceCar") is True

    def test_even_length_palindrome(self):
        """Test with even length palindrome"""
        assert buggy_script.is_palindrome("noon") is True

    def test_odd_length_palindrome(self):
        """Test with odd length palindrome"""
        assert buggy_script.is_palindrome("level") is True


class TestCountVowels:
    """Tests for count_vowels function"""

    def test_normal_text(self):
        """Test with normal text"""
        assert buggy_script.count_vowels("hello world") == 3

    def test_no_vowels(self):
        """Test with no vowels"""
        assert buggy_script.count_vowels("bcdfg") == 0

    def test_only_vowels(self):
        """Test with only vowels"""
        assert buggy_script.count_vowels("aeiou") == 5

    def test_empty_string(self):
        """Test with empty string"""
        assert buggy_script.count_vowels("") == 0

    def test_mixed_case(self):
        """Test with mixed case"""
        assert buggy_script.count_vowels("HELLO World") == 3

    def test_repeated_vowels(self):
        """Test with repeated vowels"""
        assert buggy_script.count_vowels("aaa eee iii") == 9

    def test_with_numbers(self):
        """Test with numbers and special characters"""
        assert buggy_script.count_vowels("hello123!@#") == 2


class TestFibonacci:
    """Tests for fibonacci function"""

    def test_base_cases(self):
        """Test base cases"""
        assert buggy_script.fibonacci(0) == 0
        assert buggy_script.fibonacci(1) == 1

    def test_small_numbers(self):
        """Test with small Fibonacci numbers"""
        assert buggy_script.fibonacci(2) == 1
        assert buggy_script.fibonacci(3) == 2
        assert buggy_script.fibonacci(4) == 3
        assert buggy_script.fibonacci(5) == 5
        assert buggy_script.fibonacci(6) == 8

    def test_medium_numbers(self):
        """Test with medium Fibonacci numbers"""
        assert buggy_script.fibonacci(10) == 55
        assert buggy_script.fibonacci(15) == 610

    def test_larger_numbers(self):
        """Test with larger Fibonacci numbers"""
        assert buggy_script.fibonacci(20) == 6765

    def test_negative_input(self):
        """Test with negative input"""
        assert buggy_script.fibonacci(-1) == 0
        assert buggy_script.fibonacci(-10) == 0


class TestEdgeCases:
    """Test edge cases and integration"""

    def test_calculate_average_with_large_numbers(self):
        """Test calculate_average with very large numbers"""
        large_numbers = [1000000, 2000000, 3000000]
        assert buggy_script.calculate_average(large_numbers) == 2000000.0

    def test_find_max_with_large_list(self):
        """Test find_max_value with a large list"""
        large_list = list(range(1000))
        assert buggy_script.find_max_value(large_list) == 999

    def test_palindrome_sensitivity(self):
        """Test that palindrome checking is case-insensitive"""
        assert buggy_script.is_palindrome("Racecar") is True
        assert buggy_script.is_palindrome("RACECAR") is True

    def test_vowel_count_comprehensive(self):
        """Test vowel counting with comprehensive text"""
        text = "The quick brown fox jumps over the lazy dog"
        vowels = sum(1 for char in text.lower() if char in "aeiou")
        assert buggy_script.count_vowels(text) == vowels


if __name__ == "__main__":
    # Allow running tests directly with Python
    import pytest
    pytest.main([__file__, "-v"])
