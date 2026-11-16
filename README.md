# Processador Neander em Verilog (RTL)

Implementação em Verilog do processador didático **Neander** (8 bits, acumulador), feita módulo a módulo, cada um com seu testbench, e simulada com o **Cadence Xcelium (`xrun`)**.

> **Estado atual:** projeto em andamento. O datapath (registradores, MUX e ULA), unidade de controle, decodificador estão implementados e testados. O módulo de memória ainda está em desenvolvimento**, e as pastas `asm/`, `mem/`, `scrips/`, `tb/` e `tools/` na raiz ainda estão em desenvolvimento.

## Sobre o Neander

Arquitetura simples usada no ensino de organização de computadores:

- Dados e endereços de 8 bits, memória de 256 posições.
- Um único registrador visível ao programador, o acumulador (AC).
- Duas flags de condição: **N** (negativo) e **Z** (zero).
- Contador de programa (PC) de 8 bits.
- Conjunto de instruções clássico, adicionada a instrução `SUB`: `NOP, STA, LDA, ADD, OR, AND, NOT, JMP, JN, JZ, HLT`.

## Estrutura de diretórios

```
neander/
├── rtl/
│   ├── source/        # módulos sintetizáveis (design)
│   ├── tb/            # testbenches + logs de simulação (*_log.txt)
│   └── tb_rem_reg.v   # arquivo vazio, duplicado de tb/tb_rem_reg.v
├── asm/               # (vazio) programas em assembly do Neander
├── mem/               # (vazio) imagens de memória
├── scrips/            # (vazio) scripts de automação
├── tb/                # (vazio) testbench de nível de sistema
├── tools/             # (vazio) ferramentas (ex.: montador)
└── .gitignore         # ignora xcelium.d/, xrun.log, xrun.history
```

## Processo de criação

O desenvolvimento segue a abordagem **bottom-up**: construir e validar cada bloco do datapath isoladamente, e só depois integrá-los sob uma unidade de controle.

1. **Especificação**: partir da arquitetura do Neander (diagrama de blocos do livro de Arquitetura de Computadores) e identificar os blocos: `PC`, `REM`, `RDM`, `RI`, `AC`, `NZ`, `MUX`, `ULA`, `MEM` e `UC`.
2. **Módulos parametrizados**: largura de dados em `WIDTH_DATA` (padrão 8) e de seleção da ULA em `WIDTH_SEL` (padrão 3).
3. **Testbench por módulo**: cada módulo em `rtl/source/` tem um `tb_<modulo>.v` em `rtl/tb/`, com saída registrada em `<modulo>_log.txt`.
4. **Simulação com `xrun`**: compila, elabora e simula; os artefatos gerados (`xcelium.d/`, `xrun.log`, `xrun.history`) são ignorados pelo Git.
5. **Integração (pendente)**: `mem`, módulo de topo que conecta tudo.

### Ordem seguida (conforme os arquivos existentes)

| Etapa | Módulo | Status |
|-------|--------|--------|
| 1 | Registradores `ac_reg`, `rdm_reg`, `rem_reg`, `ri_reg` | ✅ implementado e com testbench |
| 2 | `pc_reg` (com carga e incremento) | ✅ implementado e com testbench |
| 3 | `nz_reg` (flags N e Z) | ✅ implementado e com testbench |
| 4 | `mpx` (seleciona PC ou RDM para o REM) | ✅ implementado e com testbench |
| 5 | `ula` | ✅ implementado e com testbench exaustivo |
| 6 | `decod` (decodificador de instruções) | ✅ implementado e com testbench |
| 7 | `mem` (memória 256x8) | ⏳ em produção |
| 8 | `unidade_controle` (FSM de busca/decodificação/execução) | ✅ implementado e com testbench |
| 9 | Módulo de topo + testbench de sistema + programas `.asm` | ⏳ em produção |

## Módulos (`rtl/source/`)

| Módulo | Função | Portas principais |
|--------|--------|-------------------|
| `ac_reg` | Acumulador | `clk, rst, load, data_in, data_out` |
| `rdm_reg` | Registrador de dados da memória | `clk, rst, load, data_in, data_out` |
| `rem_reg` | Registrador de endereço da memória | `clk, rst, load, data_in, data_out` |
| `ri_reg` | Registrador de instrução | `clk, rst, load, data_in, data_out` |
| `pc_reg` | Contador de programa; `load` tem prioridade sobre `inc` | `clk, rst, inc, load, data_in, data_out` |
| `nz_reg` | Guarda as flags N e Z. No reset, N=0 e Z=1 | `clk, rst, load, n_in, z_in, n_out, z_out` |
| `mpx` | MUX 2:1 combinacional: `s1=0` seleciona `pc_out`, `s1=1` seleciona `rdm_out` | `s1, pc_out, rdm_out, data_out` |
| `ula` | ULA combinacional com flags N e Z | `sel, x, y, result, n_flag, z_flag` |

Todos os registradores são síncronos na borda de subida do clock, com reset síncrono de prioridade máxima, seguido de `load`.

### Operações da ULA

| `sel` | Operação | Resultado |
|-------|----------|-----------|
| `010` | LDA | `x` |
| `011` | ADD | `x + y` |
| `100` | OR | `x \| y` |
| `101` | AND | `x & y` |
| `110` | NOT | `~x` |
| `111` | SUB | `x + ~y + 1` (complemento de 2) |
| demais | | `0` |

- `z_flag = ~|result` (todos os bits zero).
- `n_flag = result[MSB]`.

## Verificação (`rtl/tb/`)

| Testbench | Estratégia |
|-----------|------------|
| `tb_ula` | Teste **exaustivo** de todas as combinações de `sel`, `x` e `y` (2^19). Compara com o modelo de referência e imprime `ERRO` e a contagem final. É o único testbench auto-verificável. |
| `tb_pc_reg` | Varre todas as combinações de `load`, `inc` e `data_in`; saída via `$monitor`. |
| `tb_nz_reg` | Varre todas as combinações de `load`, `n_in` e `z_in`. |
| `tb_ac_reg`, `tb_rdm_reg`, `tb_rem_reg`, `tb_ri_reg`, `tb_mpx` | Estímulos de varredura com `$monitor`; inspeção manual do log. |

Os logs de cada execução ficam em `rtl/tb/*_log.txt`.

## Como simular

Pré-requisito: Cadence Xcelium (testado com `xrun 24.09-s001`). A partir de `rtl/`:

```bash
cd rtl

# ULA (testbench auto-verificável)
xrun -64bit +access+rwc -timescale 10ns/1ps source/ula.v tb/tb_ula.v | tee tb/ula_log.txt

# Exemplo: contador de programa
xrun -64bit +access+rwc -timescale 10ns/1ps source/pc_reg.v tb/tb_pc_reg.v | tee tb/pc_reg_log.txt
```

Para os demais, troque os arquivos pelo par `source/<modulo>.v` e `tb/tb_<modulo>.v`.


Autor:
Emerson Nunes
