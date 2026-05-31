# 📘 Trabalho Prático 1 — Controlador de Cache RISC-V

## Integrantes

- Felipe Barros Ratton de Almeida
- Laura Menezes Heráclito Alves
- Mateus Ribeiro Fernandes
- Vitor de Meira Gomes

---

## 🎯 Objetivo

Este projeto tem como objetivo implementar e validar um controlador de cache em SystemVerilog, baseado na especificação apresentada no livro:

**Computer Organization and Design: The Hardware/Software Interface — RISC-V Edition**

O trabalho foi desenvolvido para a disciplina de Arquitetura de Computadores III e tem como foco a compreensão prática dos principais conceitos relacionados à hierarquia de memória, incluindo:

- Funcionamento de caches;
- Políticas de leitura e escrita;
- Tratamento de cache misses;
- Controle de bits valid e dirty;
- Política write-back;
- Comunicação entre cache e memória principal.

---

## 📚 Referência Teórica

A implementação segue a arquitetura apresentada no:

**Capítulo 5, Seção 5.12 — Computer Organization and Design: The Hardware/Software Interface (RISC-V Edition)**

A organização dos módulos e a estrutura geral da cache foram inspiradas diretamente no modelo de cache direct-mapped apresentado pelo livro.

---

## 🏗️ Arquitetura Implementada

O projeto implementa uma cache de mapeamento direto (*Direct-Mapped Cache*) composta pelos seguintes módulos:

| Módulo | Descrição |
|----------|----------|
| `cache_def.sv` | Definições de tipos, parâmetros e interfaces |
| `dm_cache_data.sv` | Memória de dados da cache |
| `dm_cache_tag.sv` | Memória de tags da cache |
| `dm_cache_fsm.sv` | Controlador principal da cache (FSM) |
| `memory_model.sv` | Modelo simplificado de memória principal |
| `cpu_request_model.sv` | Gerador de requisições da CPU para testes |

---

## ⚙️ Adaptações de Implementação

Embora a arquitetura siga a especificação apresentada pelo livro, algumas adaptações foram realizadas para facilitar a simulação utilizando o Icarus Verilog:

- Implementação de modelos simplificados de CPU e memória principal;
- Criação de um ambiente completo de validação funcional;
- Ajustes na FSM para compatibilidade com o simulador;
- Simplificação de algumas interfaces internas.

Essas adaptações não alteram os requisitos funcionais do controlador de cache.

---

## 📦 Estrutura do Projeto

```text
ac3-tp01-riscv-cache-controller/
├── bin/
│
├── debug/
│   ├── tb_smoke.sv
│   └── tb_smoke_memories.sv
│
├── docs/
│   ├── enunciado/
│   └── relatorio/
│
├── src/
│   ├── cache_def.sv
│   ├── cpu_request_model.sv
│   ├── dm_cache_data.sv
│   ├── dm_cache_fsm.sv
│   ├── dm_cache_tag.sv
│   └── memory_model.sv
│
├── tb/
│   ├── tb_dm_cache.sv
│   ├── tests_read.sv
│   ├── tests_write.sv
│   ├── tests_replacement.sv
│   ├── tests_consistency.sv
│   └── tests_edge_cases.sv
│
├── Makefile
├── README.md
└── .gitignore
```

---

## 🧪 Testes Implementados

O projeto contempla todos os cenários mínimos exigidos pelo enunciado.

### Leitura (Read Path)

- Cache Hit
- Cache Miss
- Atualização correta de Valid Bit
- Atualização correta de Tag

### Escrita (Write Path)

- Write Hit
- Write Miss
- Política Write-Back
- Atualização do Dirty Bit

### Substituição

- Substituição de blocos
- Escrita de blocos dirty na memória principal
- Validação da política de substituição

### Consistência

- Sequências de leitura e escrita
- Acessos repetidos ao mesmo endereço
- Conflitos de mapeamento

### Casos Limite

- Cache inicialmente vazia
- Cache totalmente inválida
- Endereços extremos

---

## 📊 Funcionalidades

- Cache Hit
- Cache Miss
- Leitura de memória
- Escrita em cache
- Write-Back
- Dirty Bit
- Valid Bit
- Controle por FSM
- Integração com memória principal
- Simulação automatizada

---

## 🛠️ Dependências

### Linux (Ubuntu/Debian)

Instalar:

```bash
sudo apt update
sudo apt install iverilog gtkwave make
```

Verificar instalação:

```bash
iverilog -V
gtkwave --version
make --version
```

Ferramentas utilizadas:

- Icarus Verilog
- GTKWave
- GNU Make

---

## ▶️ Compilação

Para compilar o projeto:

```bash
make build
```

---

## ▶️ Execução

Para executar todos os testes:

```bash
make run
```

ou

```bash
make test
```

---

## 📈 Visualização de Waveforms

Após a execução da simulação:

```bash
make wave
```

Será aberto o arquivo:

```text
bin/wave.vcd
```

para inspeção dos sinais através do GTKWave.

---

## 🧹 Limpeza

Remover arquivos gerados:

```bash
make clean
```

---

## ❓ Ajuda

Listar os comandos disponíveis:

```bash
make help
```

---

## 🪟 Windows

### Opção recomendada: WSL

```powershell
wsl --install
```

Após a instalação:

```bash
sudo apt update
sudo apt install iverilog gtkwave make
```

### Opção nativa

- Icarus Verilog: http://bleyer.org/icarus/
- GTKWave: https://gtkwave.sourceforge.net/

---

## 🐞 Sinais Relevantes para Debug

Durante a análise das waveforms recomenda-se observar:

- `hit`
- `miss`
- `valid`
- `dirty`
- `mem_req`
- `cpu_req`
- `ready`
- `rw`

---

## 🎓 Contexto Acadêmico

Projeto desenvolvido para fins acadêmicos na disciplina de Arquitetura de Computadores III.

O objetivo principal é exercitar conceitos de hierarquia de memória e projeto de hardware utilizando SystemVerilog.

---

## 📌 Licença

Uso exclusivamente acadêmico.
