# HOW TO RUN PROJECT SMARTSHOP MOBILE


#### 1. change LAN IP 

- If you run this flutter projet on your lap (localhost), use 10.0.2.2
- If you run this flutter project on your real phone:           
   - First, you need to open your CMD and run 'ipconfig' to get LAN IP  
   - Then, open file lib/core/constants/api_constants. 
   - change LAN IP in variable "ipAddress" in  file lib/core/constants/api_constants.dart.
   - save

#### 2. Run backend server
- Open link https://github.com/TakiyaYoru/SmartShop.git and clone it 
- cd to server
- run command 'npm install'
- run command 'npm start'

#### 3. Run project smartshop mobile
   
- First, run command 'flutter clean' in terminal
- Then, run command 'flutter run' in terminal