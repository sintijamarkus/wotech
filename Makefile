##
## Makefile for the my_printf project
##

CC		=	gcc
CFLAGS	=	-Wall -Wextra -Iinclude
LIB_SRC	=	src/my_printf.c \
			src/helpers.c

TEST_SRC	=	$(LIB_SRC) main.c
TEST_BIN	=	my_printf_test

all: $(TEST_BIN)

$(TEST_BIN): $(TEST_SRC)
	$(CC) $(CFLAGS) $(TEST_SRC) -o $(TEST_BIN)

## Build the test driver with AddressSanitizer to catch memory issues.
debug: fclean
	$(CC) $(CFLAGS) -g3 -fsanitize=address $(TEST_SRC) -o $(TEST_BIN)

clean:
	$(RM) *.o src/*.o

fclean: clean
	$(RM) $(TEST_BIN)

re: fclean all

.PHONY: all debug clean fclean re
