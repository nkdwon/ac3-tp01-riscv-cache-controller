# 📘 Trabalho Prático — Controlador de Cache RISC-V

# Integrantes

- Felipe Barros Ratton de Almeida
- Laura Menezes Heráclito Alves
- Mateus Ribeiro Fernandes
- Vitor de Meira Gomes

---

## 🎯 Objetivo

Este projeto tem como objetivo implementar e validar um controlador de cache em SystemVerilog, baseado na especificação apresentada no livro:

Computer Organization and Design: The Hardware/Software Interface — RISC-V Edition.

O foco do trabalho é compreender os principais conceitos relacionados à hierarquia de memória e ao funcionamento de caches.

---

## 📚 Referência Teórica

A implementação deste projeto segue o modelo apresentado no Capítulo 5, Seção 5.12 do livro:

*Computer Organization and Design: The Hardware/Software Interface — RISC-V Edition.*

A estrutura principal da cache, nomenclatura dos módulos e organização da implementação foram baseadas diretamente nos exemplos fornecidos pelo livro para uma cache direct-mapped (mapeamento direto) implementada em SystemVerilog.

Os módulos principais seguem a organização apresentada pelo material teórico:

- `cache_def.sv`: definições de tipos, parâmetros e interfaces.
- `dm_cache_data.sv`: memória de dados da cache.
- `dm_cache_tag.sv`: memória de tags da cache.
- `dm_cache_fsm.sv`: máquina de estados finitos (FSM) do controlador da cache.
- `memory_model.sv`: modelo de memória principal utilizado na simulação.
- `cpu_request_model.sv`: modelo de requisições da CPU utilizado nos testes.

---

## 📦 Estrutura do Projeto

```text
ac3-tp03-riscv-cache-controller/
├── bin/
│
├── docs/
│   ├── enunciado/
│   └── relatorio/
│
├── src/
│   ├── cache_def.sv
│   ├── dm_cache_data.sv
│   ├── dm_cache_tag.sv
│   ├── dm_cache_fsm.sv
│   ├── memory_model.sv
│   └── cpu_request_model.sv
│
├── tb/
│   ├── tb_dm_cache.sv
│   ├── tests_read.sv
│   ├── tests_write.sv
│   ├── tests_replacement.sv
│   ├── tests_consistency.sv
│   └── tests_edge_cases.sv
│
├── .gitignore
├── Makefile
└── README.md
```

---

# 🛠️ Ferramentas

## 🐧 Instalação no Ubuntu / Linux

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

Verificar instalação:

```bash
iverilog -V
gtkwave --version
```

---

## ▶️ Compilar e Executar

Para compilar e executar a simulação:

```bash
make run
```

Para visualizar a waveform:

```bash
make wave
```

Para limpar os arquivos gerados:

```bash
make clean
```

Os arquivos gerados pela simulação ficam na pasta:

```text
bin/
├── simv
└── wave.vcd
```

---

## 🪟 Windows

### ✔️ Opção recomendada: WSL

```powershell
wsl --install
```

Depois:

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

---

### ✔️ Opção nativa

- Icarus Verilog: http://bleyer.org/icarus/
- GTKWave: https://gtkwave.sourceforge.net/

---

## 📊 Funcionalidades

- Cache hit
- Cache miss
- Leitura de memória
- Escrita em cache
- Política write-back
- Controle de bits valid e dirty
- Integração com memória principal
- Máquina de estados da cache

---

## 🧠 Conceitos

### Cache Hit
Acesso a dado já presente na cache.

### Cache Miss
Dado não encontrado na cache, exigindo acesso à memória principal.

### Write-back
A memória principal é atualizada apenas quando necessário.

### Dirty Bit
Indica que um bloco foi modificado.

### Valid Bit
Indica que a linha da cache contém dados válidos.

### FSM (Finite State Machine)
Máquina de estados responsável pelo controle do funcionamento da cache.

---

## 🧪 Testes

O projeto inclui testes automatizados para:

- Read hit
- Read miss
- Write hit
- Write miss
- Escrita de blocos dirty
- Substituição de blocos
- Conflitos de cache
- Inicialização da cache
- Consistência de dados

---

## 🐞 Debug

Verificar sinais importantes:

- hit
- miss
- valid
- dirty
- mem_req
- cpu_req
- ready
- rw

---

## ⚠️ Observação

Projeto acadêmico com finalidade didática.

---

## 📌 Licença

Uso acadêmico.