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

> [!NOTE]
> Do not supply more than one channel when calling a process with multiple inputs. Invoking a process with multiple channels can lead to non-deterministic behavior. All additional inputs should be dataflow values.
Documentationda da aynı durumdan bahsediliyor, sorunun çözülmesi için `.join` kullanılmasını öneriyor.

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

---

Work directory cleanup

The clean command removes work directories and cached intermediate files from past executions.

Use this to free disk space, clean up failed or test runs, or maintain your work directory. Use -n to perform a dry run and show what would be deleted. Use -f to delete files.

nextflow clean -n

nextflow clean dreamy_euler -f