import 'package:project_netsurf/common/models/product.dart';

class Products {
  static List<Product> _productCategories = <Product>[
    new Product(1, "Natura More", "Natura More", 0, 0, 0),
    new Product(2, "Personal Care (Herbs & More)", "Personal Care", 0, 0, 0),
    new Product(3, "Home Care", "Home Care", 0, 0, 0),
    new Product(4, "Agriculture - Biofit", "Agriculture", 0, 0, 0)
  ];

  static Product getProductCategory(int id) {
    if (id == null) {
      return _productCategories[0];
    }
    return _productCategories[id];
  }

  static List<Product> getProductCategories() {
    return _productCategories;
  }

  static List<Product> getProductsFromCategoryId(Product product) {
    if (product == null || product.name.isEmpty) {
      return getDefaultProducts();
    }
    List<Product> products = [];
    switch (product.id) {
      case 1:
        products = getNaturaMore();
        break;
      case 2:
        products = getHerbsAndMore();
        break;
      case 3:
        products = getHomeCare();
        break;
      case 4:
        products = getBioFit();
        break;
    }
    return products;
  }

  static List<Product> getDefaultProducts() {
    return getNaturaMore();
  }

  static List<Product> _naturaMore = <Product>[
    new Product(1, "For Women French Venilla Flavour", "400 Gm", 1575, 1, 1),
    new Product(2, "For Men French Venilla Flavour", "400 Gm", 1700, 1, 1),
    new Product(3, "Plus French Venilla Flavour", "350 Gm", 1700, 1, 1),
    new Product(4, "Women Venilla", "350 Gm", 1400, 1, 1),
    new Product(5, "For Women Masala Milk Flavour", "350 Gm", 1400, 1, 1),
    new Product(6, "Chocolate C", "350 Gm", 1200, 1, 1),
    new Product(7, "Joint Care New", "30 Tab", 495, 1, 1),
    new Product(8, "Immune Plus", "60 Tab", 600, 1, 1),
    new Product(9, "Women's Wellness", "30 Tab", 600, 1, 1),
    new Product(10, "Eye Care", "30 Tab", 600, 1, 1),
    new Product(11, "De Stress", "30 Tab", 600, 1, 1),
    new Product(12, "Mens Wellness New", "30 Tab", 600, 1, 1),
    new Product(13, "Easy Detox", "30 Tab", 495, 1, 1),
    new Product(14, "Nutriheart", "30 Tab", 495, 1, 1),
    new Product(15, "Nutriliver", "30 Tab", 495, 1, 1),
    new Product(16, "Lifestyle Plus", "30 Tab", 450, 1, 1),
  ];

  static List<Product> getNaturaMore() {
    return _naturaMore;
  }

  static List<Product> _herbsAndMore = <Product>[
    new Product(1, "Vitamin Therapy Face Mist 100 New", "100 MLT", 280, 1, 2),
    new Product(2, "Herbs & More hygenic Pack", "1 Nos", 785, 1, 2),
    new Product(
        3, "Herbs & More Vitamin Therapy Under Eye Gel", "25 Gm", 225, 1, 2),
    new Product(4, "Vitamin Therapy Face Wash New", "100 Gm", 220, 1, 2),
    new Product(5, "Herbs & More Vitamin Therapy Face Wash For Him", "100 Gm",
        250, 1, 2),
    new Product(6, "Herbs & More Vitamin Therapy Face Wash For Her", "100 Gm",
        250, 1, 2),
    new Product(
        7, "Herbs & More Vitamin Therapy Night Cream", "50 Gm", 495, 1, 2),
    new Product(
        8, "Herbs & More Vitamin Therapy Day Cream", "50 Gm", 495, 1, 2),
    new Product(
        9, "Herbs & More Vitamin Therapy Lip Butter", "10 Gm", 180, 1, 2),
    new Product(
        10, "Herbs & More Vitamin Therapy BB Cream", "30 Gm", 280, 1, 2),
    new Product(11, "Vitamin Therapy Shaving Cream", "75 Gm", 150, 1, 2),
    new Product(12, "Vitamin Therapy Hair Nutriment", "80 Gm", 360, 1, 2),
    new Product(13, "Herbs & More Vitamin Therapy Anti Dandruff Shampoo",
        "100 MLT", 220, 1, 2),
    new Product(14, "Herbs & More Vitamin Therapy Nourishing Shampoo",
        "100 MLT", 220, 1, 2),
    new Product(
        15, "Herbs & More Vitamin Therapy Hair Serum", "100 MLT", 650, 1, 2),
    new Product(16, "Oral Cleanser", "100 MLT", 175, 1, 2),
    new Product(
        17, "Herbs & More Vitamin Therapy Body Wash", "100 MLT", 220, 1, 2),
    new Product(
        18, "Herbs & More Vitamin Therapy Body Lotion", "100 MLT", 275, 1, 2),
    new Product(
        19, "Vitamin Therapy Moisturizing Soap 5 Pkt", "350 Gm", 400, 1, 2),
    new Product(20, "Vitamin Therapy Sunscreen", "100 Gm", 395, 1, 2),
    new Product(21, "Herbs & More Vitamin Therapy Professional Massage Cream",
        "100 Gm", 220, 1, 2),
    new Product(
        22,
        "Herbs & More Vitamin Therapy Professional Cleansing Lotion",
        "100 Gm",
        220,
        1,
        2),
    new Product(23, "Herbs & More Vitamin Therapy Professional Face Pack",
        "100 Gm", 220, 1, 2),
    new Product(24, "Herbs & More Vitamin Therapy Professional Massage Gel",
        "100 Gm", 220, 1, 2),
    new Product(25, "Herbs & More Vitamin Therapy Professional Face Scrub",
        "100 Gm", 220, 1, 2),
    new Product(26, "Herbs & More Vitamin Therapy Professional Face Toner",
        "100 Gm", 220, 1, 2),
    new Product(27, "Herbal Dental Paste", "125 Gm", 180, 1, 2),
    new Product(28, "Aloe Turmeric Cream", "75 Gm", 160, 1, 2),
    new Product(29, "Herbs & More Muscular Pain Cream", "50 Gm", 250, 1, 2),
    new Product(30, "Herbs & More Crackz Cream", "50 Gm", 170, 1, 2),
    new Product(31, "Anti Pimple Cream", "75 Gm", 150, 1, 2),
    new Product(32, "Neem Turmeric Anty Septic Cream", "75 Gm", 150, 1, 2)
  ];

  static List<Product> getHerbsAndMore() {
    return _herbsAndMore;
  }

  static List<Product> _homeCare = <Product>[
    new Product(
        1, "Clean & More Fabric Wash and Conditioner", "500 MLT", 395, 1, 3),
    new Product(
        2, "Clean & More multi purpose Home Cleaner", "500 MLT", 375, 1, 3)
  ];

  static List<Product> getHomeCare() {
    return _homeCare;
  }

  static List<Product> _bioFit = <Product>[
    new Product(1, "SHET", "1 Ltr", 1200, 1, 4),
    new Product(2, "STIM RICH", "1 Ltr", 1695, 1, 4),
    new Product(3, "STIM RICH", "500 MLT", 1000, 1, 4),
    new Product(4, "STIM RICH", "250 MLT", 600, 1, 4),
    new Product(5, "N", "1 Ltr", 600, 1, 4),
    new Product(6, "P", "1 Ltr", 600, 1, 4),
    new Product(7, "K", "1 Ltr", 600, 1, 4),
    new Product(8, "Bio99", "500 MLT", 1399, 1, 4),
    new Product(9, "Bio99", "250 MLT", 749, 1, 4),
    new Product(10, "Intact", "250 MLT", 1500, 1, 4),
    new Product(11, "Wrapup", "1 Ltr", 1500, 1, 4),
    new Product(12, "Pet Lotion", "175 MLT", 550, 1, 4),
    new Product(13, "CFC", "280 Gm", 325, 1, 4),
    new Product(14, "CFC Plus", "500 Gm", 650, 1, 4),
    new Product(15, "Aqua Culture", "500 MLT", 350, 1, 4),
    new Product(16, "Aqua Clear", "250 Gm", 600, 1, 4),
    new Product(17, "Aqua Feed", "250 Gm", 400, 1, 4)
  ];

  static List<Product> getBioFit() {
    return _bioFit;
  }
}
