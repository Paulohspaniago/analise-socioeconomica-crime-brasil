# datasets

Pasta destinada aos arquivos de dados do projeto.

Organizacao sugerida:

```text
datasets/
├── crime/
├── educacao/
├── idh/
└── populacao/
```

Boas praticas:

- manter os arquivos brutos sem sobrescrever o original
- usar nomes consistentes por fonte e ano
- documentar a origem de cada arquivo no notebook de exploracao
- evitar salvar aqui arquivos finais tratados

Arquivos tratados e consolidados devem ser exportados para o MongoDB e, se necessario, para uma subpasta versionada definida depois pelo time.
