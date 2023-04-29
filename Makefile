ASFLAGS += -W

.DEFAULT_GOAL := fibonacci

# If this doesn't run, check the executable bit on test.bash
#.PHONY: check
#check: fibonacci
#check:
#	./test/test.bash

.PHONY: clean
clean:
	$(RM) fibonacci
