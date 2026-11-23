# LG-TV-CLI

LG webOS televizyonları yerel ağ üzerinden terminalden yönetmek için mini bir CLI.

## Komutlar

```
tv netflix      Netflix'i aç
tv prime        Prime Video'yu aç
tv ayarlar      Ayarlar menüsünü aç
tv sessiz       Sesi kapat / aç (aç-kapa)
tv kapat        Televizyonu kapat
tv uygulamalar  Yüklü uygulamaların ID'lerini listele
```

## Gereksinimler

- [uv](https://docs.astral.sh/uv/) (bağımlılıkları script kendisi kurar: `aiowebostv`)
- TV ile aynı ağda olmak
- TV'de **Ayarlar → Ağ → LG Connect Apps** açık olmalı

## Kurulum

```sh
ln -s "$PWD/tv" ~/.local/bin/tv   # ~/.local/bin PATH'te olmalı
```

İlk çalıştırmada TV ekranında çıkan izni kumandayla onaylayın. Eşleştirme anahtarı
`~/.config/lgtv/client_key` dosyasına (izin 600) kaydedilir.

## Ayarlar

- `LGTV_HOST`: TV'nin adresi (varsayılan `lgwebostv.home`)

## Bilinen sınırlar

- TV'yi açma komutu yok: TV kapanınca ağ bağlantısı da kapanır.
- Test edilen model: LG 55UF8507 (2015, webOS 2.0).
