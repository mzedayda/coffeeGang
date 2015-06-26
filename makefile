run:
	meteor

deploy:
	curl -o ./private/members.json http://mzedayda.meteor.com/members
	meteor deploy mzedayda.meteor.com