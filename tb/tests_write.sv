// testes de escrita: write hit, write miss e dirty bit.

task automatic testes_escrita;
	logic [31:0] dado;
	int leituras_mem;
	int escritas_mem;
	logic [31:0] endereco;
	logic [9:0] indice;

	titulo("testes de escrita");

	// prepara uma linha na cache
	endereco = endereco_cache(18'h0000, 10'd1);
	leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);

	// write hit
	escrita_com_contagem(endereco, 32'hA1A1_0001, leituras_mem, escritas_mem);
	indice = indice_cache(endereco);
	verifica(leituras_mem == 0, "write hit nao le memoria");
	verifica(escritas_mem == 0, "write hit nao escreve na memoria");
	verifica(dut.ctag.tag_dirty_mem[indice] == 1'b1, "dirty setado no write hit");

	leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);
	verifica(dado == 32'hA1A1_0001, "write hit atualiza o dado");

	// escritas repetidas com hit
	escrita_com_contagem(endereco, 32'hA1A1_0002, leituras_mem, escritas_mem);
	verifica(leituras_mem == 0, "escrita repetida nao le memoria");
	verifica(escritas_mem == 0, "escrita repetida nao escreve na memoria");
	verifica(dut.ctag.tag_dirty_mem[indice] == 1'b1, "dirty continua setado");

	leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);
	verifica(dado == 32'hA1A1_0002, "escrita repetida atualiza o dado");
	resumo_write_hit = dado;

	// write miss em linha limpa
	endereco = endereco_cache(18'h0000, 10'd2);
	escrita_com_contagem(endereco, 32'hB2B2_0002, leituras_mem, escritas_mem);
	indice = indice_cache(endereco);
	verifica(leituras_mem == 1, "write miss faz leitura para alocar");
	verifica(escritas_mem == 0, "write miss nao faz write back em linha limpa");
	verifica(dut.ctag.tag_dirty_mem[indice] == 1'b1, "dirty setado no write miss");

	leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);
	verifica(dado == 32'hB2B2_0002, "write miss grava dado correto");
	resumo_write_miss = dado;
endtask