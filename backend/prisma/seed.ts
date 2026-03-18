import { PrismaClient, Role, StoreType, StoreStatus, ProductStatus, OrderStatus } from '@prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'
import bcrypt from 'bcryptjs'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })
const prisma = new PrismaClient({ adapter })

async function main() {
  console.log('🌱 Seeding SOUKNA database with Mauritanian data...')

  // Clean existing data
  await prisma.notification.deleteMany()
  await prisma.review.deleteMany()
  await prisma.orderItem.deleteMany()
  await prisma.order.deleteMany()
  await prisma.product.deleteMany()
  await prisma.storeCategory.deleteMany()
  await prisma.store.deleteMany()
  await prisma.address.deleteMany()
  await prisma.user.deleteMany()
  await prisma.banner.deleteMany()
  await prisma.category.deleteMany()
  await prisma.siteConfig.deleteMany()
  await prisma.deliveryZone.deleteMany()

  // Hash passwords
  const adminPassword = await bcrypt.hash('Admin@Soukna2024', 12)
  const userPassword = await bcrypt.hash('Test@123', 12)

  // Create Admin
  const admin = await prisma.user.create({
    data: {
      email: 'admin@soukna.mr',
      phone: '+22222000001',
      password: adminPassword,
      name: 'Admin SOUKNA',
      role: Role.ADMIN,
      language: 'ar',
    },
  })

  // Create Customers
  const customers = await Promise.all([
    prisma.user.create({
      data: {
        email: 'aminata@gmail.com',
        phone: '+22222111001',
        password: userPassword,
        name: 'Aminata Mint Ahmed',
        role: Role.CUSTOMER,
        language: 'ar',
      },
    }),
    prisma.user.create({
      data: {
        email: 'mohamed@gmail.com',
        phone: '+22222111002',
        password: userPassword,
        name: 'Mohamed Ould Brahim',
        role: Role.CUSTOMER,
        language: 'fr',
      },
    }),
    prisma.user.create({
      data: {
        email: 'fatima@gmail.com',
        phone: '+22222111003',
        password: userPassword,
        name: 'Fatima Bint Saleck',
        role: Role.CUSTOMER,
        language: 'ar',
      },
    }),
    prisma.user.create({
      data: {
        email: 'cheikh@gmail.com',
        phone: '+22222111004',
        password: userPassword,
        name: 'Cheikh Ould Vall',
        role: Role.CUSTOMER,
        language: 'fr',
      },
    }),
    prisma.user.create({
      data: {
        email: 'mariem@gmail.com',
        phone: '+22222111005',
        password: userPassword,
        name: 'Mariem Mint Moctar',
        role: Role.CUSTOMER,
        language: 'ar',
      },
    }),
  ])

  // Create Vendors
  const vendors = await Promise.all([
    prisma.user.create({
      data: {
        email: 'vendor.restaurant@soukna.mr',
        phone: '+22222222001',
        password: userPassword,
        name: 'Sidi Ould Hamidou',
        role: Role.VENDOR,
        language: 'ar',
      },
    }),
    prisma.user.create({
      data: {
        email: 'vendor.grocery@soukna.mr',
        phone: '+22222222002',
        password: userPassword,
        name: 'Khadija Mint Tijani',
        role: Role.VENDOR,
        language: 'ar',
      },
    }),
    prisma.user.create({
      data: {
        email: 'vendor.boutique@soukna.mr',
        phone: '+22222222003',
        password: userPassword,
        name: 'Abdallahi Ould Isselmou',
        role: Role.VENDOR,
        language: 'fr',
      },
    }),
    prisma.user.create({
      data: {
        email: 'vendor.resto2@soukna.mr',
        phone: '+22222222004',
        password: userPassword,
        name: 'Oumou Bint Diagana',
        role: Role.VENDOR,
        language: 'fr',
      },
    }),
    prisma.user.create({
      data: {
        email: 'vendor.grocery2@soukna.mr',
        phone: '+22222222005',
        password: userPassword,
        name: 'Moussa Ould Sidi',
        role: Role.VENDOR,
        language: 'ar',
      },
    }),
  ])

  // Create Delivery Personnel
  const deliveryUsers = await Promise.all([
    prisma.user.create({
      data: {
        email: 'delivery1@soukna.mr',
        phone: '+22222333001',
        password: userPassword,
        name: 'Boubacar Diallo',
        role: Role.DELIVERY,
        language: 'fr',
      },
    }),
    prisma.user.create({
      data: {
        email: 'delivery2@soukna.mr',
        phone: '+22222333002',
        password: userPassword,
        name: 'Mamadou Sow',
        role: Role.DELIVERY,
        language: 'fr',
      },
    }),
  ])

  // Create Addresses for customers
  const address1 = await prisma.address.create({
    data: {
      userId: customers[0].id,
      label: 'Maison',
      street: 'Rue 42, Ilot 15',
      district: 'Tevragh-Zeina',
      city: 'Nouakchott',
      lat: 18.0858,
      lng: -15.9785,
      isDefault: true,
    },
  })

  const address2 = await prisma.address.create({
    data: {
      userId: customers[1].id,
      label: 'Domicile',
      street: 'Avenue Nasser, Ilot 8',
      district: 'Ksar',
      city: 'Nouakchott',
      lat: 18.0931,
      lng: -15.9750,
      isDefault: true,
    },
  })

  await prisma.address.create({
    data: {
      userId: customers[2].id,
      label: 'Maison',
      street: 'Rue 120, Quartier Arafat',
      district: 'Arafat',
      city: 'Nouakchott',
      lat: 18.0500,
      lng: -15.9600,
      isDefault: true,
    },
  })

  // Create Categories
  const categories = await Promise.all([
    prisma.category.create({
      data: {
        name: 'Cuisine Mauritanienne',
        nameAr: 'المطبخ الموريتاني',
        nameEn: 'Mauritanian Cuisine',
        icon: '🍖',
        storeType: StoreType.RESTAURANT,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Fast Food',
        nameAr: 'وجبات سريعة',
        nameEn: 'Fast Food',
        icon: '🍔',
        storeType: StoreType.RESTAURANT,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Épicerie',
        nameAr: 'بقالة',
        nameEn: 'Grocery',
        icon: '🛒',
        storeType: StoreType.GROCERY,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Fruits & Légumes',
        nameAr: 'فواكه وخضروات',
        nameEn: 'Fruits & Vegetables',
        icon: '🥦',
        storeType: StoreType.GROCERY,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Vêtements',
        nameAr: 'ملابس',
        nameEn: 'Clothing',
        icon: '👗',
        storeType: StoreType.BOUTIQUE,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Électronique',
        nameAr: 'إلكترونيات',
        nameEn: 'Electronics',
        icon: '📱',
        storeType: StoreType.BOUTIQUE,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Boissons',
        nameAr: 'مشروبات',
        nameEn: 'Beverages',
        icon: '🧃',
        storeType: StoreType.RESTAURANT,
        isActive: true,
      },
    }),
    prisma.category.create({
      data: {
        name: 'Pâtisserie',
        nameAr: 'حلويات',
        nameEn: 'Pastry',
        icon: '🍰',
        storeType: StoreType.RESTAURANT,
        isActive: true,
      },
    }),
  ])

  // Create Stores
  const store1 = await prisma.store.create({
    data: {
      ownerId: vendors[0].id,
      name: 'Restaurant Al Baraka',
      nameAr: 'مطعم البركة',
      description: 'Cuisine mauritanienne traditionnelle - Thiéboudienne, Méchoui, Couscous au lait de chamelle',
      descriptionAr: 'مطبخ موريتاني تقليدي - تييبوديين، مشوي، كسكس بلبن الإبل',
      type: StoreType.RESTAURANT,
      status: StoreStatus.ACTIVE,
      phone: '+22222400001',
      address: 'Avenue Charles de Gaulle, Ilot 22',
      district: 'Tevragh-Zeina',
      city: 'Nouakchott',
      lat: 18.0890,
      lng: -15.9800,
      openTime: '08:00',
      closeTime: '23:00',
      isOpen: true,
      deliveryFee: 200,
      minOrder: 1000,
      rating: 4.7,
      reviewCount: 43,
    },
  })

  const store2 = await prisma.store.create({
    data: {
      ownerId: vendors[1].id,
      name: 'Supermarché Sahel',
      nameAr: 'سوبرماركت الساحل',
      description: 'Épicerie complète avec produits frais, conserves, produits locaux mauritaniens',
      descriptionAr: 'بقالة متكاملة بمنتجات طازجة ومعلبات ومنتجات موريتانية محلية',
      type: StoreType.GROCERY,
      status: StoreStatus.ACTIVE,
      phone: '+22222400002',
      address: 'Rue El Mokhtar, Ilot 5',
      district: 'Ksar',
      city: 'Nouakchott',
      lat: 18.0940,
      lng: -15.9760,
      openTime: '07:00',
      closeTime: '22:00',
      isOpen: true,
      deliveryFee: 150,
      minOrder: 500,
      rating: 4.4,
      reviewCount: 28,
    },
  })

  const store3 = await prisma.store.create({
    data: {
      ownerId: vendors[2].id,
      name: 'Boutique Mode Nouakchott',
      nameAr: 'بوتيك موضة نواكشوط',
      description: 'Vêtements traditionnels et modernes, boubous, thobes, djellabas',
      descriptionAr: 'ملابس تقليدية وحديثة، بوبو، أثواب، جلاليب',
      type: StoreType.BOUTIQUE,
      status: StoreStatus.ACTIVE,
      phone: '+22222400003',
      address: 'Marché Capital, Stand 12',
      district: 'Dar Naim',
      city: 'Nouakchott',
      lat: 18.1050,
      lng: -15.9700,
      openTime: '09:00',
      closeTime: '20:00',
      isOpen: true,
      deliveryFee: 300,
      minOrder: 2000,
      rating: 4.2,
      reviewCount: 15,
    },
  })

  const store4 = await prisma.store.create({
    data: {
      ownerId: vendors[3].id,
      name: 'Chez Oumou - Cuisine Africaine',
      nameAr: 'عند أمو - المطبخ الأفريقي',
      description: 'Spécialités africaines: Thiébou Yapp, Mafé, Yassa Poulet, Attaya',
      descriptionAr: 'تخصصات أفريقية: تيبو ياب، مافيه، ياسا دجاج، أتاي',
      type: StoreType.RESTAURANT,
      status: StoreStatus.ACTIVE,
      phone: '+22222400004',
      address: 'Rue 150, Ilot 30',
      district: 'Teyarett',
      city: 'Nouakchott',
      lat: 18.0780,
      lng: -15.9650,
      openTime: '10:00',
      closeTime: '22:00',
      isOpen: true,
      deliveryFee: 200,
      minOrder: 800,
      rating: 4.6,
      reviewCount: 67,
    },
  })

  const store5 = await prisma.store.create({
    data: {
      ownerId: vendors[4].id,
      name: 'Épicerie Arafat Fresh',
      nameAr: 'بقالة عرفات فريش',
      description: 'Produits frais du marché, légumes locaux, dattes, mil, sorgho',
      descriptionAr: 'منتجات طازجة من السوق، خضار محلية، تمور، دخن، ذرة',
      type: StoreType.GROCERY,
      status: StoreStatus.ACTIVE,
      phone: '+22222400005',
      address: 'Marché Arafat, Ilot 88',
      district: 'Arafat',
      city: 'Nouakchott',
      lat: 18.0480,
      lng: -15.9580,
      openTime: '06:00',
      closeTime: '21:00',
      isOpen: true,
      deliveryFee: 100,
      minOrder: 300,
      rating: 4.3,
      reviewCount: 52,
    },
  })

  // Link stores to categories
  await prisma.storeCategory.createMany({
    data: [
      { storeId: store1.id, categoryId: categories[0].id },
      { storeId: store1.id, categoryId: categories[6].id },
      { storeId: store2.id, categoryId: categories[2].id },
      { storeId: store2.id, categoryId: categories[3].id },
      { storeId: store3.id, categoryId: categories[4].id },
      { storeId: store4.id, categoryId: categories[0].id },
      { storeId: store4.id, categoryId: categories[1].id },
      { storeId: store4.id, categoryId: categories[7].id },
      { storeId: store5.id, categoryId: categories[2].id },
      { storeId: store5.id, categoryId: categories[3].id },
    ],
  })

  // Create Products for Store 1 (Restaurant Al Baraka)
  const products1 = await Promise.all([
    prisma.product.create({
      data: {
        storeId: store1.id,
        categoryId: categories[0].id,
        name: 'Thiéboudienne Poisson',
        nameAr: 'تيبوديين سمك',
        nameEn: 'Fish Thieboudienne',
        description: 'Plat national mauritanien - riz au poisson avec légumes. Pour 2 personnes.',
        descriptionAr: 'الطبق الوطني الموريتاني - أرز بالسمك والخضروات. لشخصين.',
        price: 1500,
        originalPrice: 1800,
        images: ['https://res.cloudinary.com/demo/image/upload/thieboudienne.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'plat',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store1.id,
        categoryId: categories[0].id,
        name: 'Méchoui Agneau',
        nameAr: 'مشوي خروف',
        nameEn: 'Roasted Lamb',
        description: 'Agneau entier rôti à la braise, servi avec pain mauritanien et harissa',
        descriptionAr: 'خروف كامل مشوي على الجمر، يقدم مع الخبز الموريتاني والهريسة',
        price: 3500,
        images: ['https://res.cloudinary.com/demo/image/upload/mechoui.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'kg',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store1.id,
        categoryId: categories[0].id,
        name: 'Couscous Lait Chamelle',
        nameAr: 'كسكس بلبن الإبل',
        nameEn: 'Couscous with Camel Milk',
        description: 'Couscous traditionnel arrosé de lait de chamelle frais, spécialité de la maison',
        descriptionAr: 'كسكس تقليدي مع لبن إبل طازج، تخصص المطعم',
        price: 1200,
        images: ['https://res.cloudinary.com/demo/image/upload/couscous.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'plat',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store1.id,
        categoryId: categories[6].id,
        name: 'Attaya Thé Vert',
        nameAr: 'أتاي شاي أخضر',
        nameEn: 'Mauritanian Green Tea',
        description: 'Thé mauritanien à 3 tours avec menthe et sucre - tradition hassanie',
        descriptionAr: 'شاي موريتاني ثلاثة دورات بالنعناع والسكر - تقليد حساني',
        price: 300,
        images: ['https://res.cloudinary.com/demo/image/upload/attaya.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'service',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store1.id,
        categoryId: categories[0].id,
        name: 'Thiébou Yapp Mouton',
        nameAr: 'تيبو ياب خروف',
        nameEn: 'Lamb Rice',
        description: 'Riz au mouton avec légumes et épices mauritaniennes',
        descriptionAr: 'أرز بلحم الخروف مع الخضار والبهارات الموريتانية',
        price: 1800,
        originalPrice: 2000,
        images: ['https://res.cloudinary.com/demo/image/upload/thiebou_yapp.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'plat',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store1.id,
        categoryId: categories[0].id,
        name: 'Harira Mauritanienne',
        nameAr: 'حريرة موريتانية',
        nameEn: 'Mauritanian Harira Soup',
        description: 'Soupe épaisse aux lentilles, pois chiches et herbes aromatiques',
        descriptionAr: 'شوربة سميكة بالعدس والحمص والأعشاب العطرية',
        price: 500,
        images: ['https://res.cloudinary.com/demo/image/upload/harira.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'bol',
      },
    }),
  ])

  // Create Products for Store 2 (Supermarché Sahel)
  const products2 = await Promise.all([
    prisma.product.create({
      data: {
        storeId: store2.id,
        categoryId: categories[2].id,
        name: 'Riz Parfumé 5kg',
        nameAr: 'أرز فاخر 5 كجم',
        nameEn: 'Premium Rice 5kg',
        description: 'Riz basmati importé de haute qualité',
        descriptionAr: 'أرز بسمتي مستورد عالي الجودة',
        price: 2500,
        images: ['https://res.cloudinary.com/demo/image/upload/rice.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 50,
        unit: 'sac',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store2.id,
        categoryId: categories[2].id,
        name: 'Huile Végétale 1L',
        nameAr: 'زيت نباتي 1 لتر',
        nameEn: 'Vegetable Oil 1L',
        description: 'Huile de tournesol raffinée',
        descriptionAr: 'زيت عباد الشمس المكرر',
        price: 800,
        images: ['https://res.cloudinary.com/demo/image/upload/oil.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 100,
        unit: 'bouteille',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store2.id,
        categoryId: categories[3].id,
        name: 'Dattes Tidjikja 1kg',
        nameAr: 'تمر تيجيكجة 1 كجم',
        nameEn: 'Tidjikja Dates 1kg',
        description: 'Dattes mauritaniennes premium de Tidjikja, très sucrées',
        descriptionAr: 'تمور موريتانية ممتازة من تيجيكجة، حلوة جداً',
        price: 1500,
        originalPrice: 1800,
        images: ['https://res.cloudinary.com/demo/image/upload/dates.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 30,
        unit: 'kg',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store2.id,
        categoryId: categories[3].id,
        name: 'Mil Locaux 2kg',
        nameAr: 'دخن محلي 2 كجم',
        nameEn: 'Local Millet 2kg',
        description: 'Mil cultivé localement en Mauritanie, idéal pour le couscous',
        descriptionAr: 'دخن مزروع محلياً في موريتانيا، مثالي للكسكس',
        price: 600,
        images: ['https://res.cloudinary.com/demo/image/upload/mil.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 25,
        unit: 'sac',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store2.id,
        categoryId: categories[2].id,
        name: 'Thé Vert Chinois 250g',
        nameAr: 'شاي أخضر صيني 250 غ',
        nameEn: 'Chinese Green Tea 250g',
        description: 'Thé vert de Chine pour l\'attaya mauritanien',
        descriptionAr: 'شاي أخضر صيني للأتاي الموريتاني',
        price: 1200,
        images: ['https://res.cloudinary.com/demo/image/upload/tea.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 60,
        unit: 'boîte',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store2.id,
        categoryId: categories[2].id,
        name: 'Sucre Blanc 2kg',
        nameAr: 'سكر أبيض 2 كجم',
        nameEn: 'White Sugar 2kg',
        description: 'Sucre raffiné blanc',
        descriptionAr: 'سكر أبيض مكرر',
        price: 700,
        images: ['https://res.cloudinary.com/demo/image/upload/sugar.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 80,
        unit: 'paquet',
      },
    }),
  ])

  // Create Products for Store 4 (Chez Oumou)
  const products4 = await Promise.all([
    prisma.product.create({
      data: {
        storeId: store4.id,
        categoryId: categories[0].id,
        name: 'Mafé Bœuf',
        nameAr: 'مافيه لحم بقري',
        nameEn: 'Beef Mafé',
        description: 'Sauce arachide avec viande de bœuf, servi avec riz blanc',
        descriptionAr: 'صلصة الفول السوداني مع لحم البقر، تقدم مع الأرز الأبيض',
        price: 1400,
        images: ['https://res.cloudinary.com/demo/image/upload/mafe.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'plat',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store4.id,
        categoryId: categories[1].id,
        name: 'Yassa Poulet',
        nameAr: 'ياسا دجاج',
        nameEn: 'Chicken Yassa',
        description: 'Poulet mariné au citron et oignons, grillé puis mijotté',
        descriptionAr: 'دجاج متبل بالليمون والبصل، مشوي ثم مطبوخ على نار هادئة',
        price: 1600,
        originalPrice: 1900,
        images: ['https://res.cloudinary.com/demo/image/upload/yassa.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'plat',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store4.id,
        categoryId: categories[7].id,
        name: 'Zlabia Mauritanienne',
        nameAr: 'زلابية موريتانية',
        nameEn: 'Mauritanian Zlabia',
        description: 'Pâtisserie traditionnelle croustillante au miel',
        descriptionAr: 'حلوى تقليدية مقرمشة بالعسل',
        price: 400,
        images: ['https://res.cloudinary.com/demo/image/upload/zlabia.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'portion',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store4.id,
        categoryId: categories[6].id,
        name: 'Jus Bissap',
        nameAr: 'عصير الكركديه',
        nameEn: 'Bissap Juice',
        description: 'Jus d\'hibiscus frais préparé maison',
        descriptionAr: 'عصير كركديه طازج محضر في المنزل',
        price: 300,
        images: ['https://res.cloudinary.com/demo/image/upload/bissap.jpg'],
        status: ProductStatus.AVAILABLE,
        unit: 'verre',
      },
    }),
  ])

  // Create Products for Store 5 (Épicerie Arafat Fresh)
  await Promise.all([
    prisma.product.create({
      data: {
        storeId: store5.id,
        categoryId: categories[3].id,
        name: 'Tomates Fraîches 1kg',
        nameAr: 'طماطم طازجة 1 كجم',
        nameEn: 'Fresh Tomatoes 1kg',
        description: 'Tomates locales fraîches du marché Arafat',
        descriptionAr: 'طماطم محلية طازجة من سوق عرفات',
        price: 250,
        images: ['https://res.cloudinary.com/demo/image/upload/tomatoes.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 100,
        unit: 'kg',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store5.id,
        categoryId: categories[3].id,
        name: 'Oignons 2kg',
        nameAr: 'بصل 2 كجم',
        nameEn: 'Onions 2kg',
        description: 'Oignons mauritaniens de qualité',
        descriptionAr: 'بصل موريتاني جيد الجودة',
        price: 300,
        images: ['https://res.cloudinary.com/demo/image/upload/onions.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 80,
        unit: 'filet',
      },
    }),
    prisma.product.create({
      data: {
        storeId: store5.id,
        categoryId: categories[2].id,
        name: 'Farine de Blé 5kg',
        nameAr: 'طحين قمح 5 كجم',
        nameEn: 'Wheat Flour 5kg',
        description: 'Farine blanche pour pain mauritanien',
        descriptionAr: 'طحين أبيض للخبز الموريتاني',
        price: 1800,
        images: ['https://res.cloudinary.com/demo/image/upload/flour.jpg'],
        status: ProductStatus.AVAILABLE,
        stock: 40,
        unit: 'sac',
      },
    }),
  ])

  // Create Sample Orders
  const order1 = await prisma.order.create({
    data: {
      customerId: customers[0].id,
      storeId: store1.id,
      addressId: address1.id,
      deliveryUserId: deliveryUsers[0].id,
      status: OrderStatus.DELIVERED,
      subtotal: 2700,
      deliveryFee: 200,
      total: 2900,
      notes: 'Pas trop épicé SVP',
      estimatedTime: 35,
      rating: 5,
      ratingComment: 'Excellent! Très bon thiéboudienne, livraison rapide',
    },
  })

  await prisma.orderItem.createMany({
    data: [
      { orderId: order1.id, productId: products1[0].id, quantity: 1, price: 1500 },
      { orderId: order1.id, productId: products1[2].id, quantity: 1, price: 1200 },
    ],
  })

  const order2 = await prisma.order.create({
    data: {
      customerId: customers[1].id,
      storeId: store4.id,
      addressId: address2.id,
      status: OrderStatus.PREPARING,
      subtotal: 3000,
      deliveryFee: 200,
      total: 3200,
      notes: 'Merci de bien emballer',
      estimatedTime: 30,
    },
  })

  await prisma.orderItem.createMany({
    data: [
      { orderId: order2.id, productId: products4[0].id, quantity: 1, price: 1400 },
      { orderId: order2.id, productId: products4[1].id, quantity: 1, price: 1600 },
    ],
  })

  const order3 = await prisma.order.create({
    data: {
      customerId: customers[2].id,
      storeId: store2.id,
      status: OrderStatus.DELIVERED,
      subtotal: 4700,
      deliveryFee: 150,
      total: 4850,
      estimatedTime: 20,
      rating: 4,
      ratingComment: 'Bonnes dattes, emballage correct',
    },
  })

  await prisma.orderItem.createMany({
    data: [
      { orderId: order3.id, productId: products2[0].id, quantity: 1, price: 2500 },
      { orderId: order3.id, productId: products2[2].id, quantity: 1, price: 1500 },
      { orderId: order3.id, productId: products2[4].id, quantity: 1, price: 700 },
    ],
  })

  // Create Reviews
  await prisma.review.createMany({
    data: [
      {
        userId: customers[0].id,
        storeId: store1.id,
        rating: 5,
        comment: 'Meilleur restaurant mauritanien de Nouakchott! Le thiéboudienne est exceptionnel.',
        images: [],
        isVisible: true,
      },
      {
        userId: customers[1].id,
        storeId: store4.id,
        rating: 5,
        comment: 'Chez Oumou c\'est la meilleure cuisine africaine! Yassa poulet parfait.',
        images: [],
        isVisible: true,
      },
      {
        userId: customers[2].id,
        storeId: store2.id,
        rating: 4,
        comment: 'Bonne épicerie, bons prix. Les dattes de Tidjikja sont délicieuses!',
        images: [],
        isVisible: true,
      },
      {
        userId: customers[3].id,
        storeId: store1.id,
        rating: 4,
        comment: 'Très bien! Le méchoui était excellent. Je recommande.',
        images: [],
        isVisible: true,
      },
      {
        userId: customers[4].id,
        storeId: store4.id,
        rating: 5,
        comment: 'Le mafé est incroyable! Exactement comme à la maison.',
        images: [],
        isVisible: true,
      },
    ],
  })

  // Create Banners
  await prisma.banner.createMany({
    data: [
      {
        title: 'Livraison Gratuite ce Weekend!',
        titleAr: 'توصيل مجاني هذا الأسبوع!',
        image: 'https://res.cloudinary.com/demo/image/upload/banner_delivery.jpg',
        link: '/promotions',
        isActive: true,
        order: 1,
      },
      {
        title: 'Nouveaux Restaurants à Tevragh-Zeina',
        titleAr: 'مطاعم جديدة في تفرغ زينة',
        image: 'https://res.cloudinary.com/demo/image/upload/banner_restaurant.jpg',
        storeType: StoreType.RESTAURANT,
        isActive: true,
        order: 2,
      },
      {
        title: 'Épicerie Fraîche - Légumes du Jour',
        titleAr: 'بقالة طازجة - خضار اليوم',
        image: 'https://res.cloudinary.com/demo/image/upload/banner_grocery.jpg',
        storeType: StoreType.GROCERY,
        isActive: true,
        order: 3,
      },
    ],
  })

  // Create Site Config
  await prisma.siteConfig.createMany({
    data: [
      { key: 'site_name', value: 'SOUKNA' },
      { key: 'site_name_ar', value: 'سوقنا' },
      { key: 'site_description', value: 'Notre Marché Mauritanien' },
      { key: 'site_description_ar', value: 'سوقنا الموريتاني' },
      { key: 'contact_email', value: 'contact@soukna.mr' },
      { key: 'contact_phone', value: '+222 22 00 00 00' },
      { key: 'default_delivery_fee', value: '200' },
      { key: 'min_order_amount', value: '500' },
      { key: 'currency', value: 'MRU' },
      { key: 'currency_symbol', value: 'أوقية' },
      { key: 'city', value: 'Nouakchott' },
      { key: 'country', value: 'Mauritanie' },
      { key: 'timezone', value: 'Africa/Nouakchott' },
      { key: 'supported_languages', value: 'fr,ar,en' },
      { key: 'default_language', value: 'ar' },
    ],
  })

  // Create Delivery Zones
  await prisma.deliveryZone.createMany({
    data: [
      { name: 'Tevragh-Zeina', nameAr: 'تفرغ زينة', city: 'Nouakchott', baseFee: 200, isActive: true },
      { name: 'Ksar', nameAr: 'القصر', city: 'Nouakchott', baseFee: 150, isActive: true },
      { name: 'Dar Naim', nameAr: 'دار النعيم', city: 'Nouakchott', baseFee: 250, isActive: true },
      { name: 'Teyarett', nameAr: 'تيارت', city: 'Nouakchott', baseFee: 200, isActive: true },
      { name: 'Arafat', nameAr: 'عرفات', city: 'Nouakchott', baseFee: 300, isActive: true },
      { name: 'Sebkha', nameAr: 'السبخة', city: 'Nouakchott', baseFee: 250, isActive: true },
      { name: 'El Mina', nameAr: 'الميناء', city: 'Nouakchott', baseFee: 300, isActive: true },
      { name: 'Riyad', nameAr: 'الرياض', city: 'Nouakchott', baseFee: 200, isActive: true },
    ],
  })

  // Create Notifications for customers
  await prisma.notification.createMany({
    data: [
      {
        userId: customers[0].id,
        title: 'Commande Livrée!',
        body: 'Votre commande au Restaurant Al Baraka a été livrée. Bon appétit!',
        type: 'ORDER_DELIVERED',
        data: JSON.stringify({ orderId: order1.id }),
        isRead: false,
      },
      {
        userId: customers[1].id,
        title: 'Commande en Préparation',
        body: 'Chez Oumou prépare votre commande. Temps estimé: 30 min',
        type: 'ORDER_PREPARING',
        data: JSON.stringify({ orderId: order2.id }),
        isRead: false,
      },
    ],
  })

  console.log('✅ Seed completed successfully!')
  console.log(`👤 Admin: admin@soukna.mr / Admin@Soukna2024`)
  console.log(`👤 Customers: aminata@gmail.com, mohamed@gmail.com... / Test@123`)
  console.log(`🏪 Stores: ${[store1.name, store2.name, store3.name, store4.name, store5.name].join(', ')}`)
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
