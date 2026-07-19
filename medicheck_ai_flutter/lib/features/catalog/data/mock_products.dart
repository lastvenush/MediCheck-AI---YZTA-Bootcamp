import '../domain/product.dart';

abstract final class MockProducts {
  static const List<Product> all = [
    Product(
      id: 'arveles_25_mg',
      type: ProductType.medicine,
      name: 'Arveles 25 mg',
      brand: 'Menarini',
      shortDescription:
          'Deksketoprofen içeren, kısa süreli ağrıların giderilmesinde kullanılan bir ilaçtır.',
      usagePurpose:
          'Hafif ve orta şiddetteki kas-iskelet, diş ve adet ağrılarının kısa süreli semptomatik tedavisinde kullanılır.',
      importantIngredients: ['Deksketoprofen trometamol'],
      attentionPoints: [
        'Mide veya bağırsak rahatsızlığı olan kişiler kullanmadan önce sağlık profesyoneline danışmalıdır.',
        'Başka ilaçlarla birlikte kullanım öncesinde olası etkileşimler değerlendirilmelidir.',
      ],
      commonEffects: ['Mide bulantısı', 'Karın ağrısı', 'Hazımsızlık'],
      tags: ['Ağrı', 'Prospektüs özeti'],
    ),
    Product(
      id: 'parol_500_mg',
      type: ProductType.medicine,
      name: 'Parol 500 mg',
      brand: 'Atabay',
      shortDescription:
          'Parasetamol içeren, ağrı ve ateş belirtilerinde kullanılan bir ilaçtır.',
      usagePurpose:
          'Hafif ve orta şiddette ağrının giderilmesine ve ateşin düşürülmesine yardımcı olmak amacıyla kullanılır.',
      importantIngredients: ['Parasetamol'],
      attentionPoints: [
        'Karaciğer rahatsızlığı olan kişiler sağlık profesyoneline danışmalıdır.',
        'Parasetamol içeren başka ürünlerle birlikte kullanılırken toplam miktara dikkat edilmelidir.',
      ],
      commonEffects: [
        'Yan etkiler herkeste görülmez',
        'Nadiren ciltte hassasiyet',
      ],
      tags: ['Ağrı', 'Ateş'],
    ),
    Product(
      id: 'anthelios_uvmune_400',
      type: ProductType.sunscreen,
      name: 'Anthelios UVMune 400',
      brand: 'La Roche-Posay',
      shortDescription:
          'Yüksek koruma sunmak üzere formüle edilmiş SPF 50+ yüz güneş koruyucusudur.',
      usagePurpose:
          'Cildin UVA ve UVB ışınlarına maruz kalmasına karşı korunmasına yardımcı olur.',
      importantIngredients: ['Geniş spektrumlu UV filtreleri'],
      attentionPoints: [
        'Alkol içeriği çok hassas ciltlerde rahatsızlık oluşturabilir.',
        'Göz çevresiyle doğrudan temastan kaçınılmalıdır.',
      ],
      commonEffects: [
        'Hassas ciltlerde geçici kızarıklık veya rahatsızlık oluşabilir.',
      ],
      tags: ['SPF 50+', 'Akışkan doku'],
      spf: 50,
      filterType: 'Organik UV filtreleri',
      skinType: 'Tüm cilt tipleri',
      containsAlcohol: true,
      containsFragrance: false,
    ),
    Product(
      id: 'mineral_sensitive_spf_50',
      type: ProductType.sunscreen,
      name: 'Mineral Sensitive SPF 50',
      brand: 'MediCheck Demo',
      shortDescription:
          'Hassas cilt odağıyla hazırlanan mineral filtreli örnek güneş koruyucudur.',
      usagePurpose:
          'Cildin güneş ışınlarına karşı korunmasına yardımcı olmak amacıyla kullanılır.',
      importantIngredients: ['Çinko oksit', 'Titanyum dioksit'],
      attentionPoints: [
        'Mineral filtreler cilt üzerinde geçici beyaz iz bırakabilir.',
        'Yeni bir ürünü kullanmadan önce küçük bir bölgede deneme yapılabilir.',
      ],
      commonEffects: [
        'Kişisel hassasiyete bağlı kızarıklık veya rahatsızlık oluşabilir.',
      ],
      tags: ['SPF 50', 'Parfümsüz'],
      spf: 50,
      filterType: 'Mineral UV filtreleri',
      skinType: 'Hassas cilt',
      containsAlcohol: false,
      containsFragrance: false,
    ),
  ];
}
