# smartshop_mobile

1. CHANGE LAN IP 

If you run this flutter projet on your lap (localhost), use 10.0.2.2
If you run this flutter project on your real phone. First, you need to open your CMD and run 'ipconfig' to get LAN IP, then take it and:    
   - Ctrl + F to find '4000' (discover the place to change LAN IP) 
   - change LAN IP in file lib/core/constants/api_constants.dart
   - change LAN IP in file features/products/presentation/screens/product_detail_screen.dart
   - change LAN IP in file lib/features/products/presentation/widgets/product_card.dart

2. Best practice to run this project
   
- First, run command 'flutter clean' in terminal
- Then, run command 'flutter run' in terminal