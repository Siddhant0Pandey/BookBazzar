// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'बुकबजार';

  @override
  String get appTagline => 'सरल इन्भेन्टरी र क्रेडिट व्यवस्थापन';

  @override
  String get yourName => 'तपाईंको नाम';

  @override
  String get shopName => 'पसलको नाम';

  @override
  String get phoneOptional => 'फोन नम्बर (वैकल्पिक)';

  @override
  String get continueToDashboard => 'ड्यासबोर्डमा जानुहोस्';

  @override
  String get worksOffline => 'पूर्णतः अफलाइन काम गर्छ - इन्टरनेट चाहिँदैन';

  @override
  String get welcomeBack => 'स्वागत छ,';

  @override
  String get totalProducts => 'कुल उत्पादन';

  @override
  String lowInStock(int count) {
    return '$count कम स्टकमा';
  }

  @override
  String get todaysSales => 'आजको बिक्री';

  @override
  String transactions(int count) {
    return '$count कारोबार';
  }

  @override
  String get cashReceived => 'नगद प्राप्त';

  @override
  String get creditGiven => 'उधारो दिएको';

  @override
  String customers(int count) {
    return '$count ग्राहक';
  }

  @override
  String get quickActions => 'द्रुत कार्यहरू';

  @override
  String get addSale => 'बिक्री थप्नुहोस्';

  @override
  String get recordNewTransaction => 'नयाँ कारोबार दर्ता गर्नुहोस्';

  @override
  String get manageInventory => 'इन्भेन्टरी व्यवस्थापन';

  @override
  String get viewAndUpdateStock => 'स्टक हेर्नुहोस् र अपडेट गर्नुहोस्';

  @override
  String get customersAndCredit => 'ग्राहक र क्रेडिट';

  @override
  String get trackPendingPayments => 'बाँकी भुक्तानी ट्र्याक गर्नुहोस्';

  @override
  String get dailySummary => 'दैनिक सारांश';

  @override
  String get viewReportsInsights => 'रिपोर्ट र जानकारी हेर्नुहोस्';

  @override
  String get inventory => 'इन्भेन्टरी';

  @override
  String get searchProducts => 'उत्पादन खोज्नुहोस्...';

  @override
  String get all => 'सबै';

  @override
  String get lowStock => 'कम स्टक';

  @override
  String get outOfStock => 'स्टक सकियो';

  @override
  String get addProduct => 'उत्पादन थप्नुहोस्';

  @override
  String get editProduct => 'उत्पादन सम्पादन';

  @override
  String get productName => 'उत्पादनको नाम';

  @override
  String get category => 'श्रेणी';

  @override
  String get costPrice => 'लागत मूल्य';

  @override
  String get sellingPrice => 'बिक्री मूल्य';

  @override
  String get quantity => 'परिमाण';

  @override
  String get lowStockThreshold => 'कम स्टक सीमा';

  @override
  String get saveProduct => 'उत्पादन सुरक्षित गर्नुहोस्';

  @override
  String get deleteProduct => 'उत्पादन मेटाउनुहोस्';

  @override
  String get confirmDelete => 'मेटाउने पुष्टि गर्नुहोस्';

  @override
  String get deleteProductConfirm => 'के तपाईं यो उत्पादन मेटाउन चाहनुहुन्छ?';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get delete => 'मेटाउनुहोस्';

  @override
  String get productSaved => 'उत्पादन सफलतापूर्वक सुरक्षित भयो';

  @override
  String get productDeleted => 'उत्पादन मेटाइयो';

  @override
  String get insufficientStock => 'पर्याप्त स्टक छैन!';

  @override
  String get selectProduct => 'उत्पादन छान्नुहोस्';

  @override
  String get enterQuantity => 'परिमाण राख्नुहोस्';

  @override
  String get paymentMethod => 'भुक्तानी विधि';

  @override
  String get cash => 'नगद';

  @override
  String get credit => 'उधारो';

  @override
  String get totalAmount => 'कुल रकम';

  @override
  String get confirmSale => 'बिक्री पुष्टि गर्नुहोस्';

  @override
  String get step1 => 'चरण १';

  @override
  String get step2 => 'चरण २';

  @override
  String get step3 => 'चरण ३';

  @override
  String perUnit(String price) {
    return 'प्रति इकाई $price';
  }

  @override
  String unitsInStock(int count) {
    return 'स्टकमा $count इकाई';
  }

  @override
  String get saleRecorded => 'बिक्री सफलतापूर्वक दर्ता भयो!';

  @override
  String get selectProductFirst => 'पहिले उत्पादन छान्नुहोस्';

  @override
  String get selectCreditCustomer => 'उधारोको लागि ग्राहक छान्नुहोस्';

  @override
  String get searchCustomers => 'ग्राहक खोज्नुहोस्...';

  @override
  String get addNewCustomer => 'नयाँ ग्राहक थप्नुहोस्';

  @override
  String get addCustomerDetails =>
      'क्रेडिट र भुक्तानी इतिहास ट्र्याक गर्न ग्राहक विवरण थप्नुहोस्';

  @override
  String get customerName => 'ग्राहकको नाम';

  @override
  String get enterCustomerName => 'ग्राहकको नाम राख्नुहोस्';

  @override
  String get phoneNumber => 'फोन नम्बर';

  @override
  String get enterPhoneNumber => '१०-अंकको नम्बर राख्नुहोस्';

  @override
  String get usedForIdentification => 'पहिचान र सम्पर्कको लागि';

  @override
  String get addressOptional => 'ठेगाना (वैकल्पिक)';

  @override
  String get enterAddress => 'ठेगाना वा स्थान राख्नुहोस्';

  @override
  String get chooseAvatar => 'अवतार छान्नुहोस्';

  @override
  String get saveCustomer => 'ग्राहक सुरक्षित गर्नुहोस्';

  @override
  String get customerSaved => 'ग्राहक सुरक्षित भयो!';

  @override
  String get pending => 'बाँकी';

  @override
  String get collected => 'सङ्कलित';

  @override
  String get cleared => 'चुक्ता';

  @override
  String get collectPayment => 'भुक्तानी सङ्कलन';

  @override
  String get viewHistory => 'इतिहास हेर्नुहोस्';

  @override
  String get viewFullHistory => 'पूर्ण इतिहास हेर्नुहोस्';

  @override
  String get customerDetails => 'ग्राहक विवरण';

  @override
  String customerSince(String date) {
    return '$date देखि ग्राहक';
  }

  @override
  String get outstandingBalance => 'बाँकी मौज्दात';

  @override
  String get totalCredit => 'कुल उधारो';

  @override
  String get paidSoFar => 'अहिलेसम्म तिरेको';

  @override
  String get daysPending => 'दिन बाँकी';

  @override
  String days(int count) {
    return '$count दिन';
  }

  @override
  String get enterAmount => 'रकम राख्नुहोस्';

  @override
  String get confirmPayment => 'भुक्तानी पुष्टि गर्नुहोस्';

  @override
  String get transactionHistory => 'कारोबार इतिहास';

  @override
  String get creditGivenLabel => 'उधारो दिएको';

  @override
  String get paymentReceived => 'भुक्तानी प्राप्त';

  @override
  String get paymentCollected => 'भुक्तानी सङ्कलन भयो!';

  @override
  String get invalidAmount => 'अमान्य रकम';

  @override
  String get noProductsFound =>
      'कुनै उत्पादन फेला परेन।\nपहिलो उत्पादन थप्न + थिच्नुहोस्।';

  @override
  String get noCustomersFound =>
      'अहिलेसम्म कुनै ग्राहक छैन।\nग्राहक थप्न + थिच्नुहोस्।';

  @override
  String get noSalesFound => 'आज कुनै बिक्री दर्ता भएको छैन।';

  @override
  String get totalSales => 'कुल बिक्री';

  @override
  String get cashPayments => 'नगद भुक्तानी';

  @override
  String get creditPayments => 'उधारो भुक्तानी';

  @override
  String get salesBreakdown => 'बिक्री विवरण';

  @override
  String get recentTransactions => 'हालका कारोबारहरू';

  @override
  String get paymentMethods => 'भुक्तानी विधिहरू';

  @override
  String get settings => 'सेटिङ';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'English';

  @override
  String get nepali => 'नेपाली';

  @override
  String get about => 'बारेमा';

  @override
  String get version => 'संस्करण';

  @override
  String get resetData => 'सबै डाटा रिसेट गर्नुहोस्';

  @override
  String get resetConfirm =>
      'यसले सबै डाटा स्थायी रूपमा मेटाउनेछ। के तपाईं निश्चित हुनुहुन्छ?';

  @override
  String get reset => 'रिसेट';

  @override
  String get dataReset => 'सबै डाटा रिसेट भयो';

  @override
  String get nameRequired => 'नाम आवश्यक छ';

  @override
  String get priceRequired => 'मूल्य ० भन्दा बढी हुनुपर्छ';

  @override
  String get quantityRequired => 'परिमाण ० वा बढी हुनुपर्छ';

  @override
  String get phoneRequired => 'फोन नम्बर आवश्यक छ';

  @override
  String get today => 'आज';

  @override
  String daysAgo(int count) {
    return '$count दिन अघि';
  }

  @override
  String get weekAgo => '१ हप्ता अघि';

  @override
  String get justNow => 'अहिले';

  @override
  String get noOutstanding => 'कुनै बाँकी क्रेडिट छैन';

  @override
  String fromCustomers(int count) {
    return '$count ग्राहकबाट';
  }

  @override
  String get thisMonth => 'यो महिना';

  @override
  String get registered => 'कुल दर्ता';

  @override
  String get qty => 'मात्रा';

  @override
  String get price => 'मूल्य';

  @override
  String get edit => 'सम्पादन';

  @override
  String get back => 'पछाडि';

  @override
  String get menu => 'मेनु';

  @override
  String get share => 'साझा गर्नुहोस्';

  @override
  String get call => 'कल';

  @override
  String get getStarted => 'सुरु गर्नुहोस्';

  @override
  String get lowStockAlert => 'कम स्टक अलर्ट';

  @override
  String get saveChanges => 'परिवर्तन सेभ गर्नुहोस्';

  @override
  String get phone => 'फोन';
}
