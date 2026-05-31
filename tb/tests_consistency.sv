// testes de consistencia: dados mantidos apos acessos repetidos.

task automatic testes_consistencia;
	logic [31:0] dado_a;
	logic [31:0] dado_b;
	int leituras_mem;
	int escritas_mem;
	logic [31:0] endereco_a;
	logic [31:0] endereco_b;
	logic [31:0] endereco_c;
	logic [31:0] endereco_d;
	logic [9:0] indice;

	titulo("testes de consistencia");

	endereco_a = endereco_cache(18'h0000, 10'd4);
	endereco_b = endereco_cache(18'h0000, 10'd5);

	escrita_com_contagem(endereco_a, 32'h1111_1111, leituras_mem, escritas_mem);
	escrita_com_contagem(endereco_b, 32'h2222_2222, leituras_mem, escritas_mem);

	leitura_com_contagem(endereco_a, dado_a, leituras_mem, escritas_mem);
	verifica(dado_a == 32'h1111_1111, "dado a consistente");
	resumo_consistencia_a = dado_a;

	leitura_com_contagem(endereco_b, dado_b, leituras_mem, escritas_mem);
	verifica(dado_b == 32'h2222_2222, "dado b consistente");
	resumo_consistencia_b = dado_b;

	leitura_com_contagem(endereco_a, dado_a, leituras_mem, escritas_mem);
	verifica(dado_a == 32'h1111_1111, "releitura mantem dado a");

	// conflito de indice
	indice = 10'd8;
	endereco_c = endereco_cache(18'h0002, indice);
	endereco_d = endereco_cache(18'h0003, indice);

	leitura_com_contagem(endereco_c, dado_a, leituras_mem, escritas_mem);
	verifica(leituras_mem >= 1, "conflito de indice faz leitura na memoria");
	verifica(dut.ctag.tag_tag_mem[indice] == tag_cache(endereco_c), "tag atualizada no endereco c");

	leitura_com_contagem(endereco_d, dado_b, leituras_mem, escritas_mem);
	verifica(leituras_mem >= 1, "conflito de indice substitui a linha");
	verifica(dut.ctag.tag_tag_mem[indice] == tag_cache(endereco_d), "tag atualizada no endereco d");

	leitura_com_contagem(endereco_c, dado_a, leituras_mem, escritas_mem);
	verifica(leituras_mem >= 1, "novo conflito gera nova leitura");
	verifica(dut.ctag.tag_tag_mem[indice] == tag_cache(endereco_c), "tag volta para o endereco c");
endtask