.PHONY: help status log diff commit push pull save audit manuals build serve lesson

help:
	@./run.sh help

status log diff push pull audit manuals build serve:
	@./run.sh $@

# make commit m="feat(phase-NN/MM): slug"
commit:
	@./run.sh commit "$(m)"

# make save m="fix(site): ..."   (commit + push to fork)
save:
	@./run.sh save "$(m)"

# make lesson dir=phases/NN-x/MM-y
lesson:
	@./run.sh lesson "$(dir)"
