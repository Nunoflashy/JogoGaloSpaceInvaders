programa
{
	inclua biblioteca Tipos --> tipos
	inclua biblioteca Arquivos --> a
	inclua biblioteca Util --> util
	inclua biblioteca Mouse --> m
	inclua biblioteca Sons --> som
	inclua biblioteca Graficos --> g
	inclua biblioteca Teclado --> t
	inclua biblioteca Texto --> texto
	
	const inteiro JANELA_LARGURA = 1024
	const inteiro JANELA_ALTURA  = 768
	
	const logico DEBUG = verdadeiro
	
	const cadeia CAMINHO_IMAGENS = "data\\imagens\\"
	const cadeia CAMINHO_FONTS   = "data\\fonts\\"
	const cadeia CAMINHO_MUSICA  = "data\\music\\"
	const cadeia CAMINHO_SFX     = "data\\sfx\\"
	
	// Carrega uma imagem a partir da pasta local do projeto.
	// Esta funcao permite alterar as dimensoes da imagem
	// Retorna o endereco na memoria onde se encontra a imagem
	// Se a imagem nao existir, retorna -1
	funcao inteiro CarregarImagem(cadeia imagem, inteiro largura, inteiro altura)
	{
		se(a.arquivo_existe(CAMINHO_IMAGENS + imagem)) {
			inteiro img = g.carregar_imagem(CAMINHO_IMAGENS + imagem)
			img = g.redimensionar_imagem(img, largura, altura, verdadeiro)
			retorne img
		}
		retorne -1
	}

	
	// Carrega o tipo de letra a partir da pasta local do projeto.
	// Se esta existir, retorna verdadeiro, se nao existir, retorna falso 
	funcao logico CarregarFont(cadeia font)
	{
		se(a.arquivo_existe(CAMINHO_FONTS + font + ".ttf")) {
			g.carregar_fonte(CAMINHO_FONTS + font + ".ttf")
			retorne verdadeiro
		}
		retorne falso
	}

	// Carrega um som a partir da pasta local do projeto.
	// Se o som nao existir, retorna -1
	funcao inteiro CarregarSom(cadeia som) {
		se(a.arquivo_existe(CAMINHO_SFX + som)) {
			retorne som.carregar_som(CAMINHO_SFX + som)
		}

		retorne -1
	}

	funcao LiberarImagem(inteiro img) {
    		g.liberar_imagem(img)
	}

	
	logico emExecucao = verdadeiro
	
	// Estados de Jogo (GameStates)
	const inteiro ESTADO_TITLESCREEN = 0
	const inteiro ESTADO_MENU	   = 1
	const inteiro ESTADO_JOGO	   = 2
	const inteiro ESTADO_PAUSA	   = 3
	const inteiro ESTADO_CREDITOS	   = 4
	const inteiro ESTADO_INVALIDO	   = -1

	/*const*/ inteiro ESTADOS_JOGO_VALIDOS[] = {
		ESTADO_TITLESCREEN,
		ESTADO_MENU,
		ESTADO_PAUSA,
		ESTADO_CREDITOS,
		ESTADO_JOGO
	}
	
	inteiro estadoAtual = ESTADO_TITLESCREEN

	funcao inteiro ObterEstadoJogo() {
		retorne estadoAtual
	}
	
	// Funcao para definir o estado de jogo,
	// para facilitar a troca de menus, submenus e do jogo inclusive
	funcao DefinirEstadoJogo(inteiro estadoJogo) {
		para(inteiro i = 0; i < util.numero_elementos(ESTADOS_JOGO_VALIDOS); i++) {
			se(estadoJogo == ESTADOS_JOGO_VALIDOS[i]) {
				estadoAtual = estadoJogo
				retorne
			}
		}
		estadoAtual = ESTADO_INVALIDO
	}


	const inteiro SLOT_INVALIDO = 0
	
	// Representa todos os slots do jogo
	const inteiro SLOT_1 = 1, 
			    SLOT_2 = 2, 
			    SLOT_3 = 3, 
			    SLOT_4 = 4, 
			    SLOT_5 = 5, 
			    SLOT_6 = 6, 
			    SLOT_7 = 7, 
			    SLOT_8 = 8, 
			    SLOT_9 = 9

	// Slot x-axis e y-axis
	const inteiro SLOT_X = 0,
			    SLOT_Y = 1
	
	// Botoes Mouse
	const inteiro MOUSE1 = 0
	const inteiro MOUSE2 = 1
	
	// Cores
	inteiro COR_CINZA

	// Imagens
	inteiro logo			// Logo Jogo
	inteiro logoIsla		// Logo ISLA
	inteiro backgroundMenu	// BG Menu
	inteiro backgroundJogo	// BG Jogo
	inteiro nave			// Imagem da nave dentro do jogo
	inteiro naveMenu		// Imagem da nave para seleção de controlos nos menus
	inteiro player1 = 0 	// Imagem estatica Player1
	inteiro player2 = 0 	// Imagem estatica Player2
	inteiro imgPlayer1 = 0 	// Ponteiro de imagem para a imagem final do Player1
	inteiro imgPlayer2 = 0 	// Ponteiro de imagem para a imagem final do Player2
	inteiro player1s 		// Versao pequena do Player1 (usada para o cursor)
	inteiro player2s 		// Versao pequena do Player2 (usada para o cursor)
	inteiro player1gif = 0 	// Imagem animada Player1
	inteiro player2gif = 0 	// Imagem animada Player2
	inteiro imgInvader		// Imagem invader Titlescreen
	inteiro imgCreditosNaves	// Imagem invaders Creditos
	
	// Efeitos de Som
	inteiro sfxLaser
	inteiro sfxControloSelecionado
	inteiro sfxPausar
	inteiro sfxRetomar


	// Representa os slots no jogo
	// Se for JOGADOR_1, está ocupado pelo jogador 1
	// Se for JOGADOR_2, está ocupado pelo jogador 2
	/*	 0  1  2
	 * 0 [0][1][2] = Slot 1, 2, 3
	 * 1	[0][1][2] = Slot 4, 5, 6
	 * 2 [0][1][2] = Slot 7, 8, 9
	 */
	inteiro slot[3][3]

	
	const inteiro SLOT_VAZIO = 0
	

	// Funcionalidade Base AI
	logico aiAtivo = falso
	
	funcao AI_Ativar() 	  { aiAtivo = verdadeiro }
	funcao AI_Desativar() { aiAtivo = falso }
	funcao logico AI_Ativo() { retorne aiAtivo }
	////////////////////////

	funcao CriarJanela(cadeia titulo, inteiro largura, inteiro altura) {
		g.iniciar_modo_grafico(verdadeiro)
		g.definir_dimensoes_janela(largura, altura)
		g.definir_titulo_janela(titulo)
	}
	
	funcao inicio() {
		InicializarValores()
		CriarJanela("Jogo do Galo: Space Invaders Edition", JANELA_LARGURA, JANELA_ALTURA)
		
		enquanto(emExecucao) {
			AtualizarValores()
			PollEvents()
			Desenhar()
		}
		LimparMemoria()
	}


	// Converter a posição do rato em slot do jogo, isto é o que nos vai permitir
	// especificar qual slot queremos usar
	// Retorna o numero do slot consoante a posicao do rato(se estiver dentro de um slot)
	// Retorna 0 se nao estiver em cima de um slot valido
	funcao inteiro CoordParaSlot(inteiro x, inteiro y)
	{
		/*
		 * [1][2][3]
		 * [4][5][6]
		 * [7][8][9]
		 */
		// So queremos os slots se estivermos no jogo
		se(ObterEstadoJogo() != ESTADO_JOGO)
			retorne SLOT_INVALIDO
			
			
	     se	   ((x >= 384 e x <= 554) e ( y >= 96 e  y <= 288)) { retorne SLOT_1 }
          senao se((x >= 554 e x <= 724) e ( y >= 96 e  y <= 288)) { retorne SLOT_2 }
          senao se((x >= 724 e x <= 894) e ( y >= 96 e  y <= 288)) { retorne SLOT_3 }
          senao se((x >= 384 e x <= 554) e ( y >= 288 e y <= 480)) { retorne SLOT_4 }
          senao se((x >= 554 e x <= 724) e ( y >= 288 e y <= 480)) { retorne SLOT_5 }
          senao se((x >= 724 e x <= 894) e ( y >= 288 e y <= 480)) { retorne SLOT_6 }
          senao se((x >= 384 e x <= 554) e ( y >= 480 e y <= 672)) { retorne SLOT_7 }
          senao se((x >= 554 e x <= 724) e ( y >= 480 e y <= 672)) { retorne SLOT_8 }
          senao se((x >= 724 e x <= 894) e ( y >= 480 e y <= 672)) { retorne SLOT_9 }

		retorne SLOT_INVALIDO
	}

	
	 inteiro slotCoord[3][2] = {
	 	{469, 192},
	 	{639, 384},
	 	{809, 576}
 	}


	const inteiro SLOT_OCUPADO 	= 0
	const inteiro SLOT_DISPONIVEL = 1

	funcao InicializarValores()
	{
		// Cores
		COR_CINZA = g.criar_cor(80, 80, 80)

		// Imagens
		logo				  = CarregarImagem("logo.png", 614, 129)
		logoIsla 			  = CarregarImagem("isla logo.png", 136-27, 48-10)
		backgroundMenu 	  = CarregarImagem("bg.gif", JANELA_LARGURA, JANELA_ALTURA)
		backgroundJogo 	  = CarregarImagem("space.gif", JANELA_LARGURA, JANELA_ALTURA)
		nave 			  = CarregarImagem("ship.png", 70, 70)
		player1 			  = CarregarImagem("player1.png", 150, 150)
		imgPlayer1 		  = CarregarImagem("player1.png", 150, 150)
		player2 			  = CarregarImagem("player2.png", 150, 150)
		player1gif		  = CarregarImagem("player1.gif", 150, 150)
		player2gif		  = CarregarImagem("player2.gif", 150, 150)
		imgInvader		  = CarregarImagem("invader.gif", 128, 128)
		imgCreditosNaves	  = CarregarImagem("creditosPlayers.gif", 800, 114)
		// Versoes pequenas
		player1s 			  = CarregarImagem("player1.png", 40, 40)
		player2s 			  = CarregarImagem("player2.png", 40, 40)
		naveMenu 			  = CarregarImagem("ship.png", 30, 30)
		////////////////////////////////////////////////////////////////

		// Efeitos de Som
		sfxLaser 			   = CarregarSom("laser.wav")
		sfxControloSelecionado = CarregarSom("controlo_selecionado.wav")
		sfxPausar 		   = CarregarSom("pausar.wav")
		sfxRetomar 		   = CarregarSom("resumir.wav")
		///////////////////////////////////////////////////////////////

		// Esconder o cursor, iremos usar as imagens dos jogadores
		m.ocultar_cursor()

		// Definir o volume do jogo
		som.definir_volume(SFX_VOLUME)
		
		se(CarregarFont("ARCADECLASSIC")) {
			escreva("Font Carregada: Arcade Classic\n")
		}

		// Adiciona todas as opcoes nos menus
		AdicionarControlos()
	}

	funcao LimparMemoria() {
	    LiberarImagem(logo)
	    LiberarImagem(logoIsla)
	    LiberarImagem(backgroundMenu)
	    LiberarImagem(backgroundJogo)
	    LiberarImagem(nave)
	    LiberarImagem(naveMenu)
	    LiberarImagem(player1)
	    LiberarImagem(player2)
	    LiberarImagem(imgPlayer1)
	    LiberarImagem(imgPlayer2)
    	    LiberarImagem(player1s)
	    LiberarImagem(player2s)
	    LiberarImagem(player1gif)
	    LiberarImagem(player2gif)
	    LiberarImagem(imgInvader)
	    LiberarImagem(imgCreditosNaves)
	}

	
	const inteiro JOGADOR_1 = 1,
			    JOGADOR_2 = 2

	cadeia nomeJogador1 = "JOGADOR 1", 
		  nomeJogador2 = "JOGADOR 2"


	const inteiro TOTAL_PONTOS = 0
	// Valores validos para o indice deste array: TOTAL_PONTOS, JOGADOR_1 e JOGADOR_2
	inteiro pontuacao[3] = {0, 0, 0}
	
	funcao inteiro ObterPontos(inteiro jogador) 			{ retorne pontuacao[jogador] }
	funcao DefinirPontos(inteiro jogador, inteiro pontos)  { pontuacao[jogador] = pontos }
	funcao AdicionarPonto(inteiro jogador) 				{ pontuacao[jogador]++ }
	funcao RemoverPonto(inteiro jogador) 				{ pontuacao[jogador]-- }
	
	inteiro jogador = JOGADOR_1

	funcao inteiro ObterJogadorAtual() { 
		se(jogador == JOGADOR_1 ou jogador == JOGADOR_2) 
			retorne jogador 
		senao 
			retorne 0
	}

	funcao Jogador_DefinirNome(inteiro jogador, cadeia nome) {
		se(jogador == JOGADOR_1 e nome != "") 	    { nomeJogador1 = nome }
		senao se(jogador == JOGADOR_2 e nome != "") { nomeJogador2 = nome }
	}

	// Funcao usada para animar o jogador quando ganha o jogo
	funcao AnimarJogador(inteiro jogador, logico animar) {
		se(jogador == JOGADOR_1) {
			se(animar) { imgPlayer1 = player1gif } 
			senao { imgPlayer1 = player1 }
		} 
		senao se(jogador == JOGADOR_2) {
			se(animar) { imgPlayer2 = player2gif } 
			senao { imgPlayer2 = player2 }
		}
	}

	funcao inteiro ObterImagemJogador() {
		se(ObterJogadorAtual() == JOGADOR_1) 	   retorne imgPlayer1
		senao se(ObterJogadorAtual() == JOGADOR_2) retorne imgPlayer2

		retorne 0
	}
	
	/*
	 * Propriedades
	 * 
	 * Getters*/ 
	inteiro EstadoJogo // Obter o estado de jogo(GameState) de onde nos encontramos no momento, isto pode ser menu, pausa, titlescreen, jogo, etc...
	inteiro Vencedor // O jogador que ganhou o jogo
	inteiro JogadorAtual // O jogador que esta a jogar
	inteiro MouseX, MouseY // Posicao do cursor
	inteiro SlotAtual // O slot atual
	
	// Funcao usada para atualizar variaveis que possam estar em mudança constante
	funcao AtualizarValores()
	{	
		MouseX = m.posicao_x()
		MouseY = m.posicao_y()
		
		EstadoJogo 	= ObterEstadoJogo()
		JogadorAtual 	= ObterJogadorAtual()
		Vencedor 		= ObterVencedor()
		SlotAtual		= CoordParaSlot(MouseX, MouseY)
		
		ConverterSlotsParaMatriz()

		se(AI_Ativo() e Vencedor == 0) {
			AI_JogarAleatoriamente()
		}
	}

	// Matriz usada para representar os slots selecionados em formato {y, x}
	// Isto é usado por causa de limitações do portugol de não deixar devolver arrays e matrizes de uma função
	logico  slotSelecionado[3][3]
	
	funcao ConverterSlotsParaMatriz() {
		// Iterar por todos os slots e defini-los como nao selecionados
		para(inteiro y = 0; y < util.numero_colunas(slot); y++) {
			para(inteiro x = 0; x < util.numero_linhas(slot); x++) {
				slotSelecionado[y][x] = falso
			}
		}

		// Selecionar o slot ativo em formato 1-9
		// Em seguida, definir o slot como selecionado na matriz
		/* Layout de Slots em relacao de Slot para Matriz
		 * 1: (0, 0)  2: (0, 1) 3: (0, 2)
		 * 4: (1, 0)  5: (1, 1) 6: (1, 2)
		 * 7: (2, 0)  8: (2, 1) 9: (2, 2)
		 */
		escolha(SlotAtual) {
			caso 1: slotSelecionado[0][0] = verdadeiro pare
			caso 2: slotSelecionado[0][1] = verdadeiro pare
			caso 3: slotSelecionado[0][2] = verdadeiro pare
			caso 4: slotSelecionado[1][0] = verdadeiro pare
			caso 5: slotSelecionado[1][1] = verdadeiro pare
			caso 6: slotSelecionado[1][2] = verdadeiro pare
			caso 7: slotSelecionado[2][0] = verdadeiro pare
			caso 8: slotSelecionado[2][1] = verdadeiro pare
			caso 9: slotSelecionado[2][2] = verdadeiro pare
		}
	}
	
	const inteiro SFX_VOLUME = 40
	
	const inteiro SFX_PAUSAR = 2
	const inteiro SFX_DESPAUSAR = 3
	const inteiro SFX_VITORIA = 4
	
	funcao ReproduzirSom(inteiro sfx) {
		escolha(sfx) {
			caso SFX_PAUSAR: 	som.reproduzir_som(sfxPausar, falso)  pare
			caso SFX_DESPAUSAR:	som.reproduzir_som(sfxRetomar, falso) pare
		}
	}

	// Verifica se estamos dentro de um slot valido de acordo com a posicao do cursor
	funcao logico SlotValido()  {
		// Se for SLOT_INVALIDO, estamos fora dos slots
		retorne SlotAtual != SLOT_INVALIDO
	}


	//Criação de Controlos (GUI Library)
	funcao DesenharBotaoRetro(inteiro x, inteiro y, cadeia texto, real tamanho) {
		g.definir_fonte_texto("ArcadeClassic")
		g.definir_tamanho_texto(tamanho)
		g.desenhar_texto(x, y, texto)
	}


	//Função para detetar se um objeto intersecta o outro, usado para detetar a colisão
	funcao logico intersecta(inteiro x1, inteiro y1, inteiro obj1x, inteiro obj1y, inteiro obj1Largura, inteiro obj1Altura) {
		se((x1 >= obj1x e y1 >= obj1y) e (x1 <= (obj1x+obj1Largura) e y1 <= (obj1y+obj1Altura)))
			retorne verdadeiro
		retorne falso
	}

	funcao ReiniciarJogo() {
	    	LimparSlots()
	    	DefinirPontos(JOGADOR_1, 0)
	    	DefinirPontos(JOGADOR_2, 0)
	    	DecidirJogador()
	    	DefinirEstadoJogo(ESTADO_JOGO)
	}

	funcao Terminar() {
		emExecucao = falso
	}


	const inteiro MENU_NUMERO_CONTROLOS = 4
	inteiro menu_posicaoControlos[MENU_NUMERO_CONTROLOS][2]
	inteiro menu_tamanhoControlos[MENU_NUMERO_CONTROLOS][2]
	cadeia  menu_textoControlos  [MENU_NUMERO_CONTROLOS]
	logico  menu_ativoControlos  [MENU_NUMERO_CONTROLOS]
	
	const inteiro PAUSA_NUMERO_CONTROLOS = 4
	inteiro pausa_posicaoControlos[PAUSA_NUMERO_CONTROLOS][2]
	inteiro pausa_tamanhoControlos[PAUSA_NUMERO_CONTROLOS][2]
	cadeia  pausa_textoControlos	[PAUSA_NUMERO_CONTROLOS]
	logico  pausa_ativoControlos	[PAUSA_NUMERO_CONTROLOS]

	const inteiro CONTROLO_X = 0, 	 CONTROLO_Y = 1
	const inteiro CONTROLO_LARGURA = 0, CONTROLO_ALTURA = 1
	
	funcao logico Controlo_EstaAtivo(inteiro controlo) {
		escolha(EstadoJogo) {
			caso ESTADO_MENU: 	retorne menu_ativoControlos[controlo]
			caso ESTADO_PAUSA:	retorne pausa_ativoControlos[controlo]
		}

		retorne falso
	}


	funcao AdicionarControlos() {
		CriarControlo(ESTADO_MENU, CONTROLO_MENU_SINGLEPLAYER, "SINGLEPLAYER", 430, 380)
		CriarControlo(ESTADO_MENU, CONTROLO_MENU_MULTIPLAYER,  "MULTIPLAYER", 438, 440)
		CriarControlo(ESTADO_MENU, CONTROLO_MENU_CREDITOS, 	"CREDITOS", 455, 500)
		CriarControlo(ESTADO_MENU, CONTROLO_MENU_SAIR, 		"SAIR PARA O DESKTOP", 410, 590)
		
		CriarControlo(ESTADO_PAUSA, CONTROLO_PAUSA_RETOMAR,   	"RETOMAR", 460, 380)
		CriarControlo(ESTADO_PAUSA, CONTROLO_PAUSA_REINICIAR, 	"REINICIAR", 450, 440)
		CriarControlo(ESTADO_PAUSA, CONTROLO_PAUSA_SAIRMENU,  	"SAIR PARA O MENU", 420, 500)
		CriarControlo(ESTADO_PAUSA, CONTROLO_PAUSA_SAIRDESKTOP,"SAIR PARA O DESKTOP", 400, 590)
	}
	
	funcao CriarControlo(inteiro estadoJogo, inteiro controlo, cadeia texto, inteiro x, inteiro y) {
		escolha(estadoJogo) {
			caso ESTADO_MENU:
				menu_posicaoControlos[controlo][CONTROLO_X] = x
				menu_posicaoControlos[controlo][CONTROLO_Y] = y
				menu_tamanhoControlos[controlo][CONTROLO_LARGURA] = 200
				menu_tamanhoControlos[controlo][CONTROLO_ALTURA] = 24
				menu_textoControlos[controlo] = texto
			pare
			
			caso ESTADO_PAUSA:
				pausa_posicaoControlos[controlo][CONTROLO_X] = x
				pausa_posicaoControlos[controlo][CONTROLO_Y] = y
				pausa_tamanhoControlos[controlo][CONTROLO_LARGURA] = 200
				pausa_tamanhoControlos[controlo][CONTROLO_ALTURA] = 24
				pausa_textoControlos[controlo] = texto
			pare
		}
	}

	// Funcao para obter o numero de controlos consoante o GameState de onde nos encontramos
	// Retorna o numero de controlos de cada GameState se existirem controlos
	// Retorna 0 se nao existirem
	funcao inteiro ObterNumeroControlos() {
		escolha(EstadoJogo) {
	        caso ESTADO_MENU: retorne MENU_NUMERO_CONTROLOS
	        caso ESTADO_PAUSA:retorne PAUSA_NUMERO_CONTROLOS
		}

		retorne 0
	}
	
	funcao Controlos_MouseEnter() {
		//Especifico para handling individual de controlos pelo index
		//Util no caso de ser necessario uma ação diferente para um controlo especifico
	}
	
	funcao Controlos_MouseLeave() {
		//Especifico para handling individual de controlos pelo index
		//Util no caso de ser necessario uma ação diferente para um controlo especifico
	}

	funcao logico Controlo_TemAtividade() {
	    	inteiro controloX = 0, controloY = 0
	    	inteiro controloLargura = 0, controloAltura = 0

		para(inteiro controlo = 0; controlo < ObterNumeroControlos(); controlo++) {
		    	escolha(EstadoJogo) {
		        caso ESTADO_MENU:
		            controloX       = menu_posicaoControlos[controlo][CONTROLO_X]
		            controloY       = menu_posicaoControlos[controlo][CONTROLO_Y]
		            controloLargura = menu_tamanhoControlos[controlo][CONTROLO_LARGURA]
		            controloAltura  = menu_tamanhoControlos[controlo][CONTROLO_ALTURA]
		        pare
		        
		        caso ESTADO_PAUSA:
		            controloX       = pausa_posicaoControlos[controlo][CONTROLO_X]
		            controloY       = pausa_posicaoControlos[controlo][CONTROLO_Y]
		            controloLargura = pausa_tamanhoControlos[controlo][CONTROLO_LARGURA]
		            controloAltura  = pausa_tamanhoControlos[controlo][CONTROLO_ALTURA]
		        pare
		    	}

		    	se(intersecta(MouseX, MouseY, controloX, controloY, controloLargura, controloAltura)) {
		    		retorne verdadeiro
		    	}
		}
		retorne falso
	}


	funcao Controlo_DefinirEstado(inteiro controlo, logico estado) {
	    	inteiro controloX = 0, controloY = 0
	    	inteiro controloLargura = 0, controloAltura = 0
	
	    	escolha(EstadoJogo) {
	        caso ESTADO_MENU:
	            controloX       = menu_posicaoControlos[controlo][CONTROLO_X]
	            controloY       = menu_posicaoControlos[controlo][CONTROLO_Y]
	            controloLargura = menu_tamanhoControlos[controlo][CONTROLO_LARGURA]
	            controloAltura  = menu_tamanhoControlos[controlo][CONTROLO_ALTURA]
	        pare
	        
	        caso ESTADO_PAUSA:
	            controloX       = pausa_posicaoControlos[controlo][CONTROLO_X]
	            controloY       = pausa_posicaoControlos[controlo][CONTROLO_Y]
	            controloLargura = pausa_tamanhoControlos[controlo][CONTROLO_LARGURA]
	            controloAltura  = pausa_tamanhoControlos[controlo][CONTROLO_ALTURA]
	        pare
	    	}

		// Verificar se o rato está em cima(intersecta) do controlo
	    	logico condicao = intersecta(MouseX, MouseY, controloX, controloY, controloLargura, controloAltura)
	
		// Trocar a condicao se o estado for falso,
		// queremos testar se nao intersecta
	    	se(nao estado) { condicao = nao condicao }

		// Se estado == verdadeiro, testar se intersecta
		// se intersectar, definir o controlo como ativo
		// Em contrapartida, se !estado, testar se nao intersecta
		// se nao intersectar, definir o controlo como inativo
	    	se(condicao) {
	        escolha(EstadoJogo) {
	            caso ESTADO_MENU:   menu_ativoControlos[controlo] = estado pare
	            caso ESTADO_PAUSA: pausa_ativoControlos[controlo] = estado pare
	        }
	    	}
	}


	const inteiro CONTROLO_MENU_SINGLEPLAYER = 0
	const inteiro CONTROLO_MENU_MULTIPLAYER	 = 1
	const inteiro CONTROLO_MENU_CREDITOS	 = 2
	const inteiro CONTROLO_MENU_SAIR		 = 3

	const inteiro CONTROLO_PAUSA_RETOMAR	 = 0
	const inteiro CONTROLO_PAUSA_REINICIAR	 = 1
	const inteiro CONTROLO_PAUSA_SAIRMENU	 = 2
	const inteiro CONTROLO_PAUSA_SAIRDESKTOP = 3

	funcao inteiro ObterControloAtivo() {
		para(inteiro i = 0; i < ObterNumeroControlos(); i++) {
			se(Controlo_EstaAtivo(i)) retorne i
		}

		retorne -1
	}

	funcao VoltarTitlescreen() {
		se(EstadoJogo != ESTADO_TITLESCREEN) {
			DefinirEstadoJogo(ESTADO_TITLESCREEN)
		}
	}

	// Funcao para navegar o menu (incluindo sub-menus)
	funcao Menu(inteiro subMenu) {
		// Reiniciar o jogo se estivermos na pausa (quer dizer que voltámos ao menu a partir da pausa)
		// Isto é usado principalmente para ter um jogo limpo quando selecionarmos outro jogo
		se(EstadoJogo == ESTADO_PAUSA) { ReiniciarJogo() }

		// Se nao estivermos no menu que passamos como argumento
		se(EstadoJogo != subMenu) {
			escolha(subMenu) {
				caso ESTADO_MENU: 	  DefinirEstadoJogo(ESTADO_MENU) pare
				caso ESTADO_CREDITOS: DefinirEstadoJogo(ESTADO_CREDITOS) pare
				caso ESTADO_PAUSA:
					// Se estivermos no jogo
					se(EstadoJogo == ESTADO_JOGO) {
						ReproduzirSom(SFX_PAUSAR)
					}
					DefinirEstadoJogo(ESTADO_PAUSA)
				pare
			}
		}
	}
	
	funcao RetomarJogo() {
		se(EstadoJogo != ESTADO_JOGO) {
			se(EstadoJogo == ESTADO_PAUSA) {
				ReproduzirSom(SFX_DESPAUSAR)
			}
			DefinirEstadoJogo(ESTADO_JOGO)
		}
	}

	funcao SinglePlayer() {
          AI_Ativar()
          Jogador_DefinirNome(JOGADOR_2, "COMPUTADOR")
          DefinirEstadoJogo(ESTADO_JOGO)
	}
	
	funcao MultiPlayer() {
          AI_Desativar()
          Jogador_DefinirNome(JOGADOR_2, "JOGADOR 2")
          DefinirEstadoJogo(ESTADO_JOGO)
	}

	funcao PreencherSlot() {
		para(inteiro y = 0; y < 3; y++) {
			para(inteiro x = 0; x < 3; x++) {
				se(SlotSelecionado(y, x) e nao SlotOcupado(y, x)) {
					slot[y][x] = JogadorAtual
					escreva("Jogador | slot["+y+"]["+x+"] = " + slot[y][x] + "\n")
					TrocarDeJogador()
				}
			}
		}
	}
	
	funcao Controlos_MouseClick() {
		se(EstadoJogo == ESTADO_MENU) {
			escolha(ObterControloAtivo()) {
				caso CONTROLO_MENU_SINGLEPLAYER: SinglePlayer() pare
                	caso CONTROLO_MENU_MULTIPLAYER:  MultiPlayer() pare
	               caso CONTROLO_MENU_CREDITOS: 	   Menu(ESTADO_CREDITOS) pare
	               caso CONTROLO_MENU_SAIR: 	   Terminar() pare
			}
		}
		senao se(EstadoJogo == ESTADO_PAUSA) {
	        	escolha(ObterControloAtivo()) {
	        		caso CONTROLO_PAUSA_RETOMAR: 	   RetomarJogo() 	 pare
	        		caso CONTROLO_PAUSA_REINICIAR:   ReiniciarJogo() 	 pare
	        		caso CONTROLO_PAUSA_SAIRMENU:    Menu(ESTADO_MENU) pare
	        		caso CONTROLO_PAUSA_SAIRDESKTOP: Terminar()		 pare
	       	}
		}
	}
	
	funcao Janela_MouseClick() {
		// Obter o GameState onde nos encontramos no momento
		escolha(EstadoJogo) {
			caso ESTADO_TITLESCREEN:
				Menu(ESTADO_MENU)
			pare
			caso ESTADO_MENU:
			caso ESTADO_CREDITOS:
			caso ESTADO_JOGO: {
				inteiro botao = m.ler_botao() // Limitar o input a 1 botao por click

				se(SlotAtual != 0 e Vencedor == 0) {
					PreencherSlot()				
				}
			} pare
		}
	}
	logico animar = falso
	funcao Janela_KeyPress() {
		// Ler a tecla que foi pressionada
		inteiro tecla = t.ler_tecla()
		
		escolha(EstadoJogo) {
			caso ESTADO_TITLESCREEN: se(tecla == t.TECLA_ENTER) { Menu(ESTADO_MENU) } 	 pare
			caso ESTADO_MENU: 		se(tecla == t.TECLA_ESC)   { VoltarTitlescreen() } pare
			caso ESTADO_CREDITOS:
				se(tecla == t.TECLA_ESC) {
					Menu(ESTADO_MENU) // Ir para o menu
				}
			pare
			caso ESTADO_PAUSA: 		se(tecla == t.TECLA_ENTER) { RetomarJogo() } 	 pare
			caso ESTADO_JOGO:
				se(tecla == t.TECLA_ESC)   {
					Menu(ESTADO_PAUSA) // Pausar o jogo
				}
				se(tecla == t.TECLA_R) 	  { ReiniciarJogo() }
				se(tecla == t.TECLA_ENTER) {

					// Se houver um vencedor (o jogo acabou)
					se(VerificarJogo() != 0) {
						AdicionarPonto(Vencedor) // Adicionar ponto ao vencedor
						AnimarJogador(JOGADOR_1, falso)
						LimparSlots() // Limpar os slots para comecar um novo jogo
						
					}
					se(JogoAcabou()) {
						// Empate
						LimparSlots()
						
					}
				}
			pare
		}

		Debug_Menu_KeyPress(tecla)
	}
	
	logico cor = falso
	
	// Variavel usada apenas para limitar as vezes que os eventos de controlos sao disparados
	logico controloMouseEnter = falso
	
	funcao PollEvents() {
		// Se algum botao do rato estiver pressionado
		se(m.algum_botao_pressionado()) {
			Janela_MouseClick()
		}

		// Se alguma tecla do teclado estiver pressionada
		se(t.alguma_tecla_pressionada()) {
			Janela_KeyPress()
		}

		// Verificar se o controlo tem atividade (se o cursor esta em cima dele)
		se(Controlo_TemAtividade()) {
			se(nao controloMouseEnter) {
				para(inteiro i = 0; i < ObterNumeroControlos(); i++) {
					Controlo_DefinirEstado(i, verdadeiro)
				}
				// Disparar evento MouseEnter quando houver atividade
				Controlos_MouseEnter()
				
				// Disparar eventos em debug
				Debug_Controlos_MouseEvents(DEBUG_CONTROLOS_MOUSEENTER)
			}
	    		controloMouseEnter = verdadeiro
	    		

			// Como ha atividade, se um botao estiver pressionado,
			// disparar MouseClick
			se(m.algum_botao_pressionado()) {
				inteiro botao = m.ler_botao() // Limitar o input a 1 botao por click
				escreva(botao + " ")
				Controlos_MouseClick()
			}
		}
		senao {
			se(controloMouseEnter) {
				// Definir todos os controlos como inativos
		    		para(inteiro i = 0; i < ObterNumeroControlos(); i++) {
		        		Controlo_DefinirEstado(i, falso)
		    		}
		    		
				// Como nao ha atividade, disparar MouseLeave
				Controlos_MouseLeave()

				// Disparar eventos em debug
				Debug_Controlos_MouseEvents(DEBUG_CONTROLOS_MOUSELEAVE)
			}
			controloMouseEnter = falso
		}
	}

	funcao TrocarDeJogador() {
		// 1 ^ 2 = 3
		// 3 ^ 1 = 2
		// 3 ^ 2 = 1
		// Se for o jogador 1, trocamos para o 2
		// Se for o jogador 2, trocamos para o 1
		jogador = jogador ^ 3
	}

	
	funcao DecidirJogador() {
		inteiro random = util.sorteia(1, 2)
		jogador = random
	}

	// Funcao para limpar os slots do jogo,
	// usado normalmente para dar reset ao jogo.
	funcao LimparSlots() {
		para(inteiro y = 0; y < 3; y++) {
			para(inteiro x = 0; x < 3; x++) {
				slot[y][x] = SLOT_VAZIO
			}
		}
	}

	// Verifica se o slot em formato yx está ocupado,
	// usado para limitar as jogadas se não estiver livre
	funcao logico SlotOcupado(inteiro y, inteiro x) {
		retorne (slot[y][x] == JOGADOR_1 ou slot[y][x] == JOGADOR_2)
	}
	
	funcao inteiro ObterSlot(inteiro y, inteiro x) {
		se	    (slot[y][x] == JOGADOR_1) retorne JOGADOR_1
		senao se (slot[y][x] == JOGADOR_2) retorne JOGADOR_2

		retorne 0
	}

	funcao inteiro ObterVencedor() {
		retorne VerificarJogo()
	}
	
	funcao inteiro VerificarJogo() {
		
		logico possibilidades[] = {
			// Linhas
			slot[0][0] == JOGADOR_1 e slot[0][1] == JOGADOR_1 e slot[0][2] == JOGADOR_1, // 1 2 3
			slot[1][0] == JOGADOR_1 e slot[1][1] == JOGADOR_1 e slot[1][2] == JOGADOR_1, // 4 5 6
			slot[2][0] == JOGADOR_1 e slot[2][1] == JOGADOR_1 e slot[2][2] == JOGADOR_1, // 7 8 9

			// Colunas
			slot[0][0] == JOGADOR_1 e slot[1][0] == JOGADOR_1 e slot[2][0] == JOGADOR_1, // 1 4 7
			slot[0][1] == JOGADOR_1 e slot[1][1] == JOGADOR_1 e slot[2][1] == JOGADOR_1, // 2 5 8
			slot[0][2] == JOGADOR_1 e slot[1][2] == JOGADOR_1 e slot[2][2] == JOGADOR_1, // 3 6 9

			// Diagonal
			slot[0][0] == JOGADOR_1 e slot[1][1] == JOGADOR_1 e slot[2][2] == JOGADOR_1, // 1 5 9
			slot[0][2] == JOGADOR_1 e slot[1][1] == JOGADOR_1 e slot[2][0] == JOGADOR_1  // 3 5 7
			
			,
			// Linhas
			slot[0][0] == JOGADOR_2 e slot[0][1] == JOGADOR_2 e slot[0][2] == JOGADOR_2, // 1 2 3
			slot[1][0] == JOGADOR_2 e slot[1][1] == JOGADOR_2 e slot[1][2] == JOGADOR_2, // 4 5 6
			slot[2][0] == JOGADOR_2 e slot[2][1] == JOGADOR_2 e slot[2][2] == JOGADOR_2, // 7 8 9

			// Colunas
			slot[0][0] == JOGADOR_2 e slot[1][0] == JOGADOR_2 e slot[2][0] == JOGADOR_2, // 1 4 7
			slot[0][1] == JOGADOR_2 e slot[1][1] == JOGADOR_2 e slot[2][1] == JOGADOR_2, // 2 5 8
			slot[0][2] == JOGADOR_2 e slot[1][2] == JOGADOR_2 e slot[2][2] == JOGADOR_2, // 3 6 9

			// Diagonal
			slot[0][0] == JOGADOR_2 e slot[1][1] == JOGADOR_2 e slot[2][2] == JOGADOR_2, // 1 5 9
			slot[0][2] == JOGADOR_2 e slot[1][1] == JOGADOR_2 e slot[2][0] == JOGADOR_2  // 3 5 7
		}
		
		para(inteiro i = 0; i < util.numero_elementos(possibilidades); i++) {
			se(possibilidades[i]) {
				se(i <= 7) { escreva("VerificarJogo() JOGADOR_1\n") retorne JOGADOR_1 }
				senao	 { escreva("VerificarJogo() JOGADOR_2\n") retorne JOGADOR_2 }
			}
		}
		
		retorne 0
	}

	// Determina se o jogo acabou contando os slots
	// Se chegar aos 9 slots, sabemos que acabou porque o jogo tem
	// 9 slots no total, independentemente de quem estiver a ocupar o slot
	funcao logico JogoAcabou() {

		inteiro slotsContados = 0
		
		para(inteiro y = 0; y < 3; y++) {
			para(inteiro x = 0; x < 3; x++) {
				// Se o slot tiver um jogador
				se(ObterSlot(y, x) != 0) {
					slotsContados++
				}
			}
		}

		se(slotsContados == 9) retorne verdadeiro
		senao			   retorne falso
		
	}

	funcao AI_JogarAleatoriamente() {
		se(nao JogoAcabou()) {
			inteiro x = util.sorteia(0, 2)
			inteiro y = util.sorteia(0, 2)

			enquanto(JogadorAtual == JOGADOR_2 e SlotOcupado(y, x)) {
				x = util.sorteia(0, 2)
				y = util.sorteia(0, 2)
			}
			
			se(JogadorAtual == JOGADOR_2 e nao SlotOcupado(y, x)) {
				slot[y][x] = JOGADOR_2
				TrocarDeJogador()
			}
		}
	}
	
	inteiro slotAtualY, slotAtualX
	inteiro ultimoSlotY, ultimoSlotX
	
	
	funcao DesenharTabuleiro() {
		g.definir_cor(g.COR_BRANCO)
		
		//Desenhar Y-axis
		g.desenhar_linha(554, 96, 554, 672)
		g.desenhar_linha(724, 96, 724, 672)

		//Desenhar X-axis
		g.desenhar_linha(384, 288, 894, 288)
		g.desenhar_linha(384, 480, 894, 480) 
	}

	// Desenhar imagem no ponto do cursor dependendo do jogador atual
	// Se for o turno do jogador 1, desenha
	funcao DesenharCursor(inteiro jogador) {
		inteiro imgCursor = 0
		se(jogador == 1) imgCursor = player1s
		senao 		  imgCursor = player2s
		
		DesenharImagemAlpha(MouseX-15, MouseY-15, imgCursor, 70)
		g.definir_opacidade(255)
	}

	funcao DesenharTexto(inteiro x, inteiro y, cadeia texto, real tamanho) {
		g.definir_tamanho_texto(tamanho)
		g.desenhar_texto(x, y, texto)
	}
	
	funcao DesenharTextoFont(inteiro x, inteiro y, cadeia font, cadeia texto, real tamanho) {
		g.definir_fonte_texto(font)
		DesenharTexto(x, y, texto, tamanho)
	}

	funcao DesenharImagem(inteiro x, inteiro y, inteiro img) {
		g.desenhar_imagem(x, y, img)
	}

	funcao DesenharImagemAlpha(inteiro x, inteiro y, inteiro img, inteiro alpha) {
		g.definir_opacidade(alpha)
		DesenharImagem(x, y, img)
	}
	
	funcao DesenharBackground() {
		escolha(EstadoJogo) {
			caso ESTADO_TITLESCREEN: DesenharImagemAlpha(0, 0, backgroundMenu, 50) pare
			caso ESTADO_MENU: 		DesenharImagemAlpha(0, 0, backgroundMenu, 255) pare
			caso ESTADO_CREDITOS: 	DesenharImagemAlpha(100, 0, imgCreditosNaves, 255) pare
			caso ESTADO_PAUSA: 		DesenharImagemAlpha(0, 0, backgroundMenu, 255) pare
			caso ESTADO_JOGO: 		DesenharImagemAlpha(0, 0, backgroundJogo, 255) pare
		}
	}

	
	funcao SelecionarOpcaoCoord(inteiro x, inteiro y) {
	    inteiro mov = util.sorteia(1, 2)
	    DesenharImagem(x+mov, y, naveMenu)
	}

	funcao SelecionarOpcaoControlo(inteiro controlo) {
	    	const inteiro distanciaNave = 40
	    	const inteiro yOffset       = 7
	
	    	inteiro x = -distanciaNave
	    	inteiro y = -yOffset
	
	    	escolha(EstadoJogo) {
	        caso ESTADO_MENU:
	            x += menu_posicaoControlos[controlo][CONTROLO_X]
	            y += menu_posicaoControlos[controlo][CONTROLO_Y]
	        pare
	        
	        caso ESTADO_PAUSA:
	            x += pausa_posicaoControlos[controlo][CONTROLO_X]
	            y += pausa_posicaoControlos[controlo][CONTROLO_Y]
	        pare
	    	}
		g.definir_cor(g.COR_BRANCO)
	    	SelecionarOpcaoCoord(x, y)
	}


	
	// Permite desenhar todos os controlos especificados nos arrays acima,
	// Assim em vez de varias configuracoes para mostrar um botão, só precisamos de adicionar
	// onde se encontram, o seu tamanho e o seu texto, esta funcao irá iterar pelos controlos todos
	// e verificar se estão ativos ou inativos.
	funcao DesenharControlos() {
	    	inteiro controloX = 0, controloY = 0
	    	inteiro controloLargura = 0, controloAltura = 0
	    	cadeia  controloTexto = ""

	    	para(inteiro controlo = 0; controlo < ObterNumeroControlos(); controlo++) {
	    		escolha(EstadoJogo) {
    				caso ESTADO_MENU:
		            controloX       = menu_posicaoControlos[controlo][CONTROLO_X]
		            controloY       = menu_posicaoControlos[controlo][CONTROLO_Y]
		            controloLargura = menu_tamanhoControlos[controlo][CONTROLO_LARGURA]
		            controloAltura  = menu_tamanhoControlos[controlo][CONTROLO_ALTURA]
		            controloTexto   = menu_textoControlos[controlo]
	    			pare
	    			
		        	caso ESTADO_PAUSA:
		            controloX       = pausa_posicaoControlos[controlo][CONTROLO_X]
		            controloY       = pausa_posicaoControlos[controlo][CONTROLO_Y]
		            controloLargura = pausa_tamanhoControlos[controlo][CONTROLO_LARGURA]
		            controloAltura  = pausa_tamanhoControlos[controlo][CONTROLO_ALTURA]
		            controloTexto   = pausa_textoControlos[controlo]
		        	pare
	    		}
	    	
	        se(Controlo_EstaAtivo(controlo)) {
            	// Controlo Ativo
            	SelecionarOpcaoControlo(controlo)
	        } 
	        senao {
	        	// Controlo Inativo
	            g.definir_cor(COR_CINZA)
	        }
	        // Desenhar Botao para o Controlo
	        DesenharBotaoRetro(controloX, controloY, controloTexto, 24.0)
	    	}

		//Fim de desenho de controlos, dar reset às cores
	    	g.definir_cor(g.COR_BRANCO)
	}

	funcao DesenharHUD() {
		g.definir_cor(g.COR_BRANCO)
		g.definir_fonte_texto("ArcadeClassic"))
		g.definir_tamanho_texto(24.0)
		
		g.desenhar_texto(40, 30, nomeJogador1)
		g.desenhar_texto(55, 50, "PONTOS")
		g.desenhar_texto(85, 70, tipos.inteiro_para_cadeia(ObterPontos(JOGADOR_1), 10))
		
		g.desenhar_texto(180, 30, nomeJogador2)
		g.desenhar_texto(195, 50, "PONTOS")
		g.desenhar_texto(225, 70, tipos.inteiro_para_cadeia(ObterPontos(JOGADOR_2), 10))

		// Mostrar quem esta a jogar
		DesenharTexto(30, JANELA_ALTURA-60, "A JOGAR", 16.0)
		DesenharTexto(20, JANELA_ALTURA-40, "JOGADOR " + tipos.inteiro_para_cadeia(jogador, 10), 16.0)
	}

	funcao DesenharNave() {	
		inteiro naveY
		
		// Limitar a nave a estas coordenadas
		se(MouseY > 120 e MouseY < 570) { naveY = MouseY }
		senao se(MouseY>= 570) 		  { naveY = 570 }
		senao 					  { naveY = 120 }
		////////////////////////////////////
		
		g.desenhar_imagem(30, naveY, nave)
	}


	// Verifica se o slot está selecionado atualmente
	funcao logico SlotSelecionado(inteiro y, inteiro x) {
		retorne slotSelecionado[y][x]
	}

	funcao DesenharJogadores_MouseEnter() {
		// Diminuir a opacidade da imagem enquanto o rato esta em cima do slot
		g.definir_opacidade(50)

		inteiro imagemJogador = ObterImagemJogador()
		
		para(inteiro y = 0; y < 3; y++) {
			para(inteiro x = 0; x < 3; x++) {
				se(SlotSelecionado(y, x) e nao SlotOcupado(y, x)) {
					DesenharImagem(slotCoord[x][SLOT_X]-75, slotCoord[y][SLOT_Y]-75, imagemJogador)
				}
			}
		}
	}
	
	funcao DesenharJogadores() {
		// Restaurar a opacidade da imagem quando for para desenhar a imagem do jogador
		g.definir_opacidade(255)

		// Desenhar os jogadores nos slots
		para(inteiro y = 0; y < 3; y++) {
			para(inteiro x = 0; x < 3; x++) {
				se(slot[y][x] == JOGADOR_1) {
					DesenharImagem(slotCoord[x][0]-75, slotCoord[y][1]-75, imgPlayer1)
				}
				senao se(slot[y][x] == JOGADOR_2) {
					DesenharImagem(slotCoord[x][0]-75, slotCoord[y][1]-75, imgPlayer2)
				}
			}
		}
	}
	
	funcao Desenhar() {
		g.definir_cor(g.COR_PRETO)
		g.limpar()
		
		// Desenhar a background de onde nos encontramos no momento
		DesenharBackground()

		// Mudar o comportamento (neste caso o que temos a desenhar) do programa dependendo de onde nos encontramos (Titlescreen, Menu, Jogo, etc...)
		escolha(EstadoJogo){
			caso ESTADO_TITLESCREEN: {
				DesenharImagemAlpha(JANELA_LARGURA-800, 100, logo, 140)
				g.definir_opacidade(255)
				g.definir_cor(g.COR_BRANCO)
				g.definir_fonte_texto("ArcadeClassic")
				DesenharTexto(JANELA_LARGURA/2-160, JANELA_ALTURA-200, "PRESSIONE ENTER PARA JOGAR", 24.0)
				DesenharTexto(20, JANELA_ALTURA-70, "DESENVOLVEDORES", 16.0)
				DesenharTexto(50, JANELA_ALTURA-50, "Nuno Nunes", 14.0)
				DesenharTexto(30, JANELA_ALTURA-35, "Daniel Oliveira", 14.0)
				DesenharImagem(JANELA_LARGURA/2-(128/2), 250, imgInvader)

				DesenharCursor(JOGADOR_1)
			} pare
			
			caso ESTADO_MENU: {
				DesenharImagem(JANELA_LARGURA-800, 100, logo)
				DesenharControlos()
				Debug_DesenharMenu()
				DesenharCursor(JOGADOR_1)
				
			} pare

			caso ESTADO_CREDITOS: {
				g.definir_cor(g.COR_BRANCO)
				DesenharTextoFont(JANELA_LARGURA/2-60, MouseY, "ArcadeClassic", "Nuno Nunes", 24.0)
				DesenharTextoFont(JANELA_LARGURA/2-90, MouseY+40, "ArcadeClassic", "Daniel Oliveira", 24.0)
				DesenharImagem(JANELA_LARGURA/2-50, MouseY+180, logoIsla)
				DesenharTextoFont(40, JANELA_ALTURA-50, "ArcadeClassic", "ESC PARA VOLTAR", 24.0)
			} pare
			
			caso ESTADO_PAUSA: {
				DesenharImagem(JANELA_LARGURA-800, 100, logo)
				DesenharControlos()
				g.definir_cor(g.COR_BRANCO)
				DesenharCursor(JOGADOR_1)
			} pare
			
			caso ESTADO_JOGO: {
				DesenharHUD()
				DesenharNave()
				DesenharTabuleiro()
				DesenharCursor(JogadorAtual)

				// Se houver um vencedor (o jogo acabou)
				se(VerificarJogo() != 0) {
					DesenharTexto(300, JANELA_ALTURA-50, "O Jogo acabou!", 20.0)
					DesenharTexto(300, JANELA_ALTURA-30, "Pressione Enter para jogar novamente", 20.0)
				}
				// Jogo empatou
				senao se(JogoAcabou()) {
					DesenharTexto(300, JANELA_ALTURA-50, "Empate!", 20.0)
					DesenharTexto(300, JANELA_ALTURA-30, "Pressione Enter para jogar novamente", 20.0)
				}
				
				// MouseEnter no Slot
				DesenharJogadores_MouseEnter()
				DesenharJogadores()

				// Animar o vencedor do jogo
				escolha(Vencedor) {
					caso JOGADOR_1: AnimarJogador(JOGADOR_1, verdadeiro) pare
					caso JOGADOR_2: AnimarJogador(JOGADOR_2, verdadeiro) pare
					caso contrario:
						AnimarJogador(JOGADOR_1, falso)
						AnimarJogador(JOGADOR_2, falso) 
					pare
				}
				/////////////
			} pare
		}

		Debug_DesenharCoordRato()
		
		// Poupar trabalho ao CPU (CPU Throttle 5ms)
		util.aguarde(5)

		// Renderizar a imagem (Trocar o buffer de tras para a frente)
		g.renderizar()

	}

	



	/* **** Funcoes Debug ****/





	// Mostra o estado de jogo atual
	funcao cadeia Debug_EstadoJogo()
	{
		se(DEBUG) {
			escolha(ObterEstadoJogo()) {
				caso ESTADO_TITLESCREEN: retorne "ESTADO_TITLESCREEN\n"
				caso ESTADO_MENU: 		retorne "ESTADO_MENU\n"
				caso ESTADO_PAUSA: 		retorne "ESTADO_PAUSA\n"
				caso ESTADO_CREDITOS:	retorne "ESTADO_CREDITOS\n"
				caso ESTADO_JOGO: 		retorne "ESTADO_JOGO\n"
			}
			
			retorne "ESTADO_INVALIDO\n"
		}

		retorne ""
	}

	funcao Debug_DesenharMenu() {
		se(DEBUG) {
			DesenharTexto(30, 425, "MENU DEBUG", 24.0)
			DesenharTexto(30, 460, "F9 IR PARA O MENU", 16.0)
			DesenharTexto(30, 480, "F10 PAUSAR O JOGO", 16.0)
			DesenharTexto(30, 500, "F11 IR PARA O JOGO", 16.0)
			DesenharTexto(30, 520, "F12 VER GAMESTATE", 16.0)
		}	
	}

	funcao Debug_Menu_KeyPress(inteiro tecla) {
		se(DEBUG) {
			escolha(tecla) {
				caso t.TECLA_F8:  VoltarTitlescreen() pare
				caso t.TECLA_F9:  Menu(ESTADO_MENU) pare
				caso t.TECLA_F10: Menu(ESTADO_PAUSA) pare
				caso t.TECLA_F11: DefinirEstadoJogo(ESTADO_JOGO) pare
				caso t.TECLA_F12: escreva("GameState: " + Debug_EstadoJogo()) pare
			}
		}
	}

	funcao Debug_DesenharCoordRato() {
		se(DEBUG) {
			DesenharTexto(JANELA_LARGURA-60, 10, "X " + m.posicao_x(), 20.0)
			DesenharTexto(JANELA_LARGURA-60, 30, "Y " + m.posicao_y(), 20.0)
		}
	}

	const inteiro DEBUG_CONTROLOS_MOUSELEAVE = 0
	const inteiro DEBUG_CONTROLOS_MOUSEENTER = 1
	
	funcao Debug_Controlos_MouseEvents(inteiro evento) {
		se(DEBUG) {
			se(evento == DEBUG_CONTROLOS_MOUSELEAVE) {
				escreva("Controlos_MouseLeave()\n")
			}
			senao se(evento == DEBUG_CONTROLOS_MOUSEENTER) {
				escreva("Controlos_MouseEnter()\n")
				cadeia estadoJogoStr = ""
				escolha(ObterEstadoJogo()) {
					caso ESTADO_MENU:  estadoJogoStr = "ESTADO_MENU" pare
					caso ESTADO_PAUSA: estadoJogoStr = "ESTADO_PAUSA" pare
				}
				escreva("Controlo: ["+estadoJogoStr+"][" + ObterControloAtivo() + "]" + "\n")
			}
		}
	}
	 /* ****			  ****/
}
/* $$$ Portugol Studio $$$ 
 * 
 * Esta seção do arquivo guarda informações do Portugol Studio.
 * Você pode apagá-la se estiver utilizando outro editor.
 * 
 * @POSICAO-CURSOR = 1740; 
 * @PONTOS-DE-PARADA = ;
 * @SIMBOLOS-INSPECIONADOS = ;
 * @FILTRO-ARVORE-TIPOS-DE-DADO = inteiro, real, logico, cadeia, caracter, vazio;
 * @FILTRO-ARVORE-TIPOS-DE-SIMBOLO = variavel, vetor, matriz, funcao;
 */