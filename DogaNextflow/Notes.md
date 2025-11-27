# Nextflow Notları
## Tuple
tuple eğer birden fazla değeri process dışına tek bir örnek olarak çıkartıcaksak kullanılıyor. Mesela klasör adı ve prefix birlikte kullanılması gerekiyorsa ikisini de tek bir değer olarak çıkartıp sonrasında başka bir process içinde ikiye ayırabiliyoruz.
```
process one {
    output:
    tuple path("klasör adı"), val("prefix")
}

process two {
    input:
    tuple path("klasör adı"), val("prefix")
    path başka_bir_klasör
}

workflow{
    ikili_seçenek = one(input)
    sonuç = two(ikili_seçenek, başka_bir_klasör)
}
```

Normalde pythonda `os.path.basename` ile benzer bişey yapılabiliyordu. Prefix için input dosyasının basename i alınıyordu, klasör adı ise sonuçların olduğu klasör içinde sabir bir klasör adı oluyordu ve `os.path.join` ile birleştiriliyordu.
Listelere benzer şekilde işliyor.
## Combine
Bir process içerisine birden fazla kanal ekleyeceksek kullanılıyor. Mesela hem fastq hem de referans dosyalarının kanalları kullanılması gerekiyorsa, kanallar .combine ile birleştirilip sonrasında kullanılacakları process içinde tuple ile açılmaları gerekir.
Bunun dışında bir kanal ve bir listenin birleştirilmesi için de kullanılıyor.

Ayrıca hem tuple hem de combine için birleştirilen variable'ların yerleri önemli, input sırası birlşetiğinde oluşan listenin sırasında olmalı. Yoksa yanlış input yanlış yere gider.
## Main ve Publish
Publish, normalde sonuçların belirli bir yere gönderilmesini sağlayan publishDir özelliğinin yerine geçmek için kullanılıyor. 
Yani eğer başka bir workflow bu workflow tarafından üretilen bir dosyayı kullanmak istiyorsa ya publishDir yada output ile tanımlanan bir noktada olması gerekiyor.
```
workflow {
    main:
    ch_step1 = step1()
    ch_step2 = step2(ch_step1)

    publish:
    step1 = ch_step1
    step2 = ch_step2
}

output {
    step1 {
        path 'step1'
    }
    step2 {
        path 'step2'
    }
}
```
Bu şekilde olan bir kod çalıştırıldığında:
```
results/
└── step1/
    └── ...
└── step2/
    └── ...
```
şöyle bir klasör elde ediliyor.