run:
	meteor

deploy:
	curl -o ./private/members.json http://coffeegang.meteor.com/members
	meteor deploy coffeegang.meteor.com