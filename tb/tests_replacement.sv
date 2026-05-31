// testes de substituicao: conflitos e write back de linha dirty.

task automatic testes_substituicao;
	logic [31:0] dado;
	int leituras_mem;
	int escritas_mem;
	logic [31:0] endereco;
	logic [31:0] endereco_limpo_b;
	logic [31:0] endereco_dirty_a;
	logic [31:0] endereco_dirty_b;
	logic [9:0] indice_limpo;
	logic [9:0] indice_dirty;
	logic [9:0] indice_loop;
	int i;
	bit cache_cheia;

	titulo("testes de substituicao");

	// preenche toda a cache com tag 0
	for (i = 0; i < 1024; i++) begin
		indice_loop = i[9:0];
		endereco = endereco_cache(18'h0000, indice_loop);
		leitura_com_contagem(endereco, dado, leituras_mem, escritas_mem);
	end

	cache_cheia = 1'b1;
	for (i = 0; i < 1024; i++) begin
		if (dut.ctag.tag_valid_mem[i] != 1'b1) begin
			cache_cheia = 1'b0;
		end
		if (dut.ctag.tag_tag_mem[i] != 18'h0000) begin
			cache_cheia = 1'b0;
		end
	end
	verifica(cache_cheia, "cache preenchida com tag 0 em todos os indices");

	// conflito em linha limpa
	indice_limpo = 10'd6;
	endereco_limpo_b = endereco_cache(18'h0001, indice_limpo);
	verifica(dut.ctag.tag_dirty_mem[indice_limpo] == 1'b0, "linha limpa antes do conflito");
	leitura_com_contagem(endereco_limpo_b, dado, leituras_mem, escritas_mem);
	verifica(escritas_mem == 0, "conflito em linha limpa nao faz write back");
	verifica(dut.ctag.tag_tag_mem[indice_limpo] == tag_cache(endereco_limpo_b), "tag atualizada em linha limpa");

	// conflito em linha dirty
	indice_dirty = 10'd7;
	endereco_dirty_a = endereco_cache(18'h0000, indice_dirty);
	endereco_dirty_b = endereco_cache(18'h0001, indice_dirty);
	leitura_com_contagem(endereco_dirty_a, dado, leituras_mem, escritas_mem);
	escrita_com_contagem(endereco_dirty_a, 32'hC3C3_0003, leituras_mem, escritas_mem);
	verifica(dut.ctag.tag_dirty_mem[indice_dirty] == 1'b1, "linha marcada como dirty");
	leitura_com_contagem(endereco_dirty_b, dado, leituras_mem, escritas_mem);
	verifica(escritas_mem >= 1, "substituicao com dirty faz write back");
	verifica(dut.ctag.tag_tag_mem[indice_dirty] == tag_cache(endereco_dirty_b), "tag atualizada na substituicao");
	verifica(dut.ctag.tag_dirty_mem[indice_dirty] == 1'b0, "dirty limpo apos alocar leitura");
	verifica(mem.memory[indice_dirty][31:0] == 32'hC3C3_0003, "memoria recebeu o dado do write back");
	resumo_writeback_mem = mem.memory[indice_dirty][31:0];

	// volta ao endereco antigo para garantir miss e dado correto
	leitura_com_contagem(endereco_dirty_a, dado, leituras_mem, escritas_mem);
	verifica(leituras_mem == 1, "reacesso apos substituicao gera miss");
	verifica(dado == 32'hC3C3_0003, "write back manteve o dado na memoria");
endtask