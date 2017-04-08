# 🎩 Jarvis
![](http://schrismart.in/jarvis-vapor/badge.svg)

Jarvis is a bot made with the intention of providing additonal functionality to the GroupMe group messaging platform. 

## 📖 Documentation

You can check out the documentation for this project by visiting [here](http://schrismart.in/jarvis-vapor).

## 📱 Usage

Currently, the bot will respond to the following commands: 

* `jarvis echo [message]` – Jarvis will respond to the group with "Echo: [message]".
* `jarvis info messages` – Jarvis will tell how many messages the group has sent
* `jarvis info members` – Jarvis will tell about how many people are in the group.
* `jarvis info age` – Jarvis will respond with the created date of the group.

More commands are being added every day. Check back for an updated list. 

## 🔧 Building

To build this project, you should be able to clone the project and use `swift build`. A more comprehensive build can be triggered by calling `vapor build`. The Project requires three environment variables to be set: 

- `GROUP_ID` – This is the identifier for the group that the bot is present in.
- `BOT_ID` – Used to make calls as the bot in question.
- `BOT_NAME` – This determines the Bot's name – for our purposes, we like to use `Jarvis`, although this is fully configurable.
- `ACCESS_TOKEN` – This is your user access token granted to you on GroupMe page. This is a requirement in order to query for information about your group.
