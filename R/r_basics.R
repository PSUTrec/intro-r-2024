#### R Basics ####
# "A foolish consistency is the hobgoblin of 
#   little minds"   -Ralph Waldo Emerson 

# Literals ----
"this is a string literal"  # double quotes preferred in R but not required
42
T
F
TRUE
FALSE

# Operators ----
# Arithmetic
2 + 3  # note the spacing
2 - 3
2 * 3  # multiplication
2 ** 3  # but be careful; this is an exponent
2 / 3
2 ^ 3  # that's better

# Comparsion
2 == 2  # tests for equality 
"Joe" == "joe"  # case-sensitive
"Joe" == "Joe"
2 == 1 + 1  # OK
2 == (1 + 1)  # better

2 != 1  # tests inequality

2 < 3
2 > 3
2 <= 2
2 >= 3

# somewhat of a cruel joke
TRUE == 1  # 
FALSE == 0  
isTRUE(TRUE)  # function testing if the argument is literally TRUE
isTRUE(1)
?isTRUE  # queries built-in help

2 < 3 & 2 > 3  # both have to pass to return TRUE
2 < 3 | 2 > 3  # either one TRUE, all TRUE
2 < 3 & (2 == 1 | 2 == 2)  # grouping statements for ordering

# type matters (sometimes)
"joe"  # string or character type
typeof("joe")
42  # numeric type (double precision, floating point)
typeof(42)
TRUE
typeof(TRUE)  # logical or boolean type

42 == "42"  # equality can cross types
identical(42, "42")  # type matters for identity


# variables ----


# data structures ----
# vectors have a single dimension, like a column or row of data

# data frames - the key structure for data science, multi-dimensional
#   collections of vectors


# Special type: factors, and putting it all together ----
# factors are categorical variables with a fixed set of
#   potential values


