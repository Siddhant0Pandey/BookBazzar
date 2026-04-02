// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BookBaazar';

  @override
  String get appTagline => 'Simple Inventory & Credit Management';

  @override
  String get yourName => 'Your Name';

  @override
  String get shopName => 'Shop Name';

  @override
  String get phoneOptional => 'Phone Number (Optional)';

  @override
  String get continueToDashboard => 'Continue to Dashboard';

  @override
  String get worksOffline => 'Works completely offline - No internet needed';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get totalProducts => 'Total Products';

  @override
  String lowInStock(int count) {
    return '$count low in stock';
  }

  @override
  String get todaysSales => 'Today\'s Sales';

  @override
  String transactions(int count) {
    return '$count transactions';
  }

  @override
  String get cashReceived => 'Cash Received';

  @override
  String get creditGiven => 'Credit Given';

  @override
  String customers(int count) {
    return '$count customers';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addSale => 'Add Sale';

  @override
  String get recordNewTransaction => 'Record new transaction';

  @override
  String get manageInventory => 'Manage Inventory';

  @override
  String get viewAndUpdateStock => 'View and update stock';

  @override
  String get customersAndCredit => 'Customers & Credit';

  @override
  String get trackPendingPayments => 'Track pending payments';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get viewReportsInsights => 'View reports and insights';

  @override
  String get inventory => 'Inventory';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get all => 'All';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get category => 'Category';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get lowStockThreshold => 'Low Stock Threshold';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteProductConfirm =>
      'Are you sure you want to delete this product?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get productSaved => 'Product saved successfully';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get insufficientStock => 'Insufficient stock!';

  @override
  String get selectProduct => 'Select Product';

  @override
  String get enterQuantity => 'Enter Quantity';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get credit => 'Credit';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get confirmSale => 'Confirm Sale';

  @override
  String get step1 => 'Step 1';

  @override
  String get step2 => 'Step 2';

  @override
  String get step3 => 'Step 3';

  @override
  String perUnit(String price) {
    return '$price per unit';
  }

  @override
  String unitsInStock(int count) {
    return '$count units in stock';
  }

  @override
  String get saleRecorded => 'Sale recorded successfully!';

  @override
  String get selectProductFirst => 'Please select a product first';

  @override
  String get selectCreditCustomer => 'Select Customer for Credit';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get addNewCustomer => 'Add New Customer';

  @override
  String get addCustomerDetails =>
      'Add customer details to track credit and payment history';

  @override
  String get customerName => 'Customer Name';

  @override
  String get enterCustomerName => 'Enter customer name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter 10-digit number';

  @override
  String get usedForIdentification => 'Used for identification and contact';

  @override
  String get addressOptional => 'Address (Optional)';

  @override
  String get enterAddress => 'Enter address or location';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get saveCustomer => 'Save Customer';

  @override
  String get customerSaved => 'Customer saved!';

  @override
  String get pending => 'Pending';

  @override
  String get collected => 'Collected';

  @override
  String get cleared => 'Cleared';

  @override
  String get collectPayment => 'Collect Payment';

  @override
  String get viewHistory => 'View History';

  @override
  String get viewFullHistory => 'View Full History';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String customerSince(String date) {
    return 'Customer since $date';
  }

  @override
  String get outstandingBalance => 'Outstanding Balance';

  @override
  String get totalCredit => 'Total Credit';

  @override
  String get paidSoFar => 'Paid So Far';

  @override
  String get daysPending => 'Days Pending';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get creditGivenLabel => 'Credit Given';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get paymentCollected => 'Payment collected!';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get noProductsFound =>
      'No products found.\nTap + to add your first product.';

  @override
  String get noCustomersFound => 'No customers yet.\nTap + to add a customer.';

  @override
  String get noSalesFound => 'No sales recorded today.';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get cashPayments => 'Cash Payments';

  @override
  String get creditPayments => 'Credit Payments';

  @override
  String get salesBreakdown => 'Sales Breakdown';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get nepali => 'नेपाली';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get resetData => 'Reset All Data';

  @override
  String get resetConfirm =>
      'This will delete ALL data permanently. Are you sure?';

  @override
  String get reset => 'Reset';

  @override
  String get dataReset => 'All data has been reset';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get priceRequired => 'Price must be greater than 0';

  @override
  String get quantityRequired => 'Quantity must be 0 or more';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get today => 'Today';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get weekAgo => '1 week ago';

  @override
  String get justNow => 'Just now';

  @override
  String get noOutstanding => 'No outstanding credit';

  @override
  String fromCustomers(int count) {
    return 'From $count customers';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String get registered => 'Total registered';

  @override
  String get qty => 'Qty';

  @override
  String get price => 'Price';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get menu => 'Menu';

  @override
  String get share => 'Share';

  @override
  String get call => 'Call';

  @override
  String get getStarted => 'Get Started';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get phone => 'Phone';
}
