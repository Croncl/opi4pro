# Contribuindo com o opi4pro

Este repositório reúne guias práticos sobre o Orange Pi 4 Pro. Para adicionar um novo tema:

## 1. Crie uma pasta em `docs/`

```
docs/<nome-do-tema>/
├── README.md          ← obrigatório
├── troubleshooting.md ← opcional
└── scripts/           ← opcional
```

Use nomes curtos e descritivos, em minúsculas e com hífen (ex.: `nvme-migration`, `gpio-setup`, `docker-arm64`).

## 2. Estrutura sugerida para o README.md do guia

- **Objetivo** — o que o leitor vai alcançar
- **Contexto/por quê** — limitações de hardware ou software relevantes
- **Pré-requisitos**
- **Passo a passo** — comandos testados, com explicação do "porquê" de cada um
- **Resumo final** — tabela ou checklist de verificação
- **Link para troubleshooting.md**, se existir

## 3. Scripts

- Scripts devem ser idempotentes sempre que possível (rodar duas vezes não deve quebrar nada)
- Comece com `set -euo pipefail` em scripts bash
- Documente uso no topo do próprio script e referencie no README do guia

## 4. Atualize o índice

Adicione uma linha na tabela de "Guias disponíveis" no [README.md](README.md) raiz.

## 5. Pull Request

- Um guia por PR, se possível
- Teste os comandos na placa real antes de enviar
- Descreva no PR qual hardware/SO você usou para validar
