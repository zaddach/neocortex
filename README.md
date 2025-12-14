# neocortex

This is an OpenWebUI instance with MCP tools for reverse engineering and vulnerability discovery.latest

## Setup
Run
```sh
docker compose up
```
to start the containers. This will take a while, and eventually bring up Open WebUI (You see a huge ASCII art logo printed in the docker compose output). Now you can log in to [http://localhost:8080](http://localhost:8080). You need to create an admin account.

Once you've done that, click on your user in the top right corner, choose "Admin Panel", "Settings", "Models" and click the tiny download button "⤓" symbol on the top right. I've used "llama3.2:3b" as model tag, just make sure that the model you're using supports tool use. Pull the model.



## Resources
- https://osintteam.blog/mcp-as-your-malware-analysis-assistant-75c177b2788f
- https://medium.com/@richard.meyer596/multi-source-rag-with-hybrid-search-and-re-ranking-in-openwebui-8762f1bdc2c6
- [FatalSec: Build an AI-Powered Reverse Engineering Lab with Ghidra](https://www.youtube.com/watch?v=WOsVlzEXxJk&pp=ygUKZ2hpZHJhIG1jcA%3D%3D)
- [OALabs: Automated AI Reverse Engineering with MCP for IDA and Ghidra (Live VIBE RE)](https://www.youtube.com/watch?v=iFxNuk3kxhk)