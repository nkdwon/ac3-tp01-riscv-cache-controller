// testes de casos limite: enderecos extremos e cache vazia.

task automatic testes_casos_limite;
	logic [31:0] dado;
	int leituras_mem;
	int escritas_mem;
	logic [31:0] endereco_min;
	logic [31:0] endereco_max;
	logic [9:0] indice;

	titulo("testes de casos limite");

	// endereco minimo alinhado
	endereco_min = 32'h0000_0000;
	leitura_com_contagem(endereco_min, dado, leituras_mem, escritas_mem);
	verifica(leituras_mem == 0 || leituras_mem == 1, "acesso ao endereco minimo responde");
	verifica(dado == dado_inicial_memoria(endereco_min), "endereco minimo retorna dado valido");
	resumo_edge_min = dado;

	// endereco maximo alinhado (indice 1023)
	endereco_max = 32'hFFFF_FFF0;
	indice = indice_cache(endereco_max);
	leitura_com_contagem(endereco_max, dado, leituras_mem, escritas_mem);
	verifica(leituras_mem == 1, "endereco maximo faz leitura na memoria");
	verifica(dut.ctag.tag_valid_mem[indice] == 1'b1, "valid setado no endereco maximo");
	verifica(dut.ctag.tag_tag_mem[indice] == tag_cache(endereco_max), "tag salva no endereco maximo");
	resumo_edge_max = dado;
endtask