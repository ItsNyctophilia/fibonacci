ASFLAGS += -W

.DEFAULT_GOAL := fibonacci

# If this doesn't run, check the executable bit on check.sh
.PHONY: check
check: fibonacci
check:
	./test/check.sh

.PHONY: clean
clean:
	$(RM) fibonacci
