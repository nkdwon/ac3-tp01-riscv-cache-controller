// testes de leitura: read hit, read miss e bits valid/tag.

task automatic testes_leitura;
	logic [31:0] dado;
	int leituras_mem;
	int escritas_mem;
	logic [31:0] endereco;
	logic [9:0] indice;
	int i;
	bit cache_invalida;
	bit dirty_limpo;

	titulo("testes de leitura");

	// cache comecando vazia
	cache_invalida = 1'b1;
	dirty_limpo = 1'b1;
	for (i = 0; i < 1024; i++) begin
		if (dut.ctag.tag_valid_mem[i] != 1'b0) begin
			cache_invalida = 1'b0;
		end
		if (dut.ctag.tag_dirty_mem[i] != 1'b0) begin
			dirty_limpo = 1'b0;
		end
	end
	verifica(cache_invalida, "cache completamente invalida apos reset");
	verifica(dirty_limpo, "dirty limpo em toda a cache");

	// read miss
	endereco = 32'h0000_0000;
	indice = indice_cache(endereco);
	leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);
	verifica(leituras_mem == 1, "read miss faz leitura na memoria");
	verifica(escritas_mem == 0, "read miss nao faz escrita na memoria");
	verifica(dado == dado_inicial_memoria(endereco), "read miss retorna dado correto");
	verifica(dut.ctag.tag_valid_mem[indice] == 1'b1, "valid setado apos read miss");
	verifica(dut.ctag.tag_tag_mem[indice] == tag_cache(endereco), "tag salva apos read miss");
	verifica(dut.ctag.tag_dirty_mem[indice] == 1'b0, "dirty limpo apos read miss");
	resumo_read_miss = dado;

	// read hit
	leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);
	verifica(leituras_mem == 0, "read hit nao acessa memoria");
	verifica(escritas_mem == 0, "read hit nao escreve na memoria");
	verifica(dado == dado_inicial_memoria(endereco), "read hit retorna dado correto");
	resumo_read_hit = dado;
endtask