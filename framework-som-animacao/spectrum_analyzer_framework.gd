extends Node3D

## Referência ao nó reprodutor de áudio (deve ser AudioStreamPlayer comum para música global)
@onready var music_player: AudioStreamPlayer = $MusicPlayer

## Instância em tempo real do analisador de espectro de áudio
var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance

# ==============================================================================
# CONSTANTES DE CONFIGURAÇÃO DE ÁUDIO
# ==============================================================================

## Frequência máxima em Hertz analisada pelas funções de banda.
## O ouvido humano ouve até ~20.000 Hz, mas grande parte da energia musical
## (bateria, graves, voz, guitarras) concentra-se abaixo de 11.000 Hz.
const FREQ_MAX: float = 11050.0

## Faixa dinâmica mínima em Decibéis (dB).
## Sons com volume abaixo de -60 dB serão tratados como silêncio absoluto (0.0).
## 60 dB de faixa dinâmica cobre com folga a maioria das produções musicais.
const MIN_DB: float = 60.0

## Tamanho da janela da FFT (Fast Fourier Transform).
## Deve ser o mesmo valor configurado no efeito SpectrumAnalyzer do painel Audio.
## Valores típicos: 512, 1024, 2048 ou 4096.
const FFT_SIZE: int = 2048

## Resolução de frequência: quantos Hertz cabem dentro de cada "fatia" (bin) da FFT
var hz_por_bin: float = 0.0


func _ready() -> void:
	# 1. Obtém o efeito SpectrumAnalyzer anexado no canal Master (bus 0, slot de efeito 0).
	# Se o efeito não existir no Audio Bus do projeto, retornará null.
	spectrum_analyzer = AudioServer.get_bus_effect_instance(0, 0)
	
	if not spectrum_analyzer:
		push_error("ERRO: Efeito SpectrumAnalyzer não encontrado no bus Master (índice 0, efeito 0).")
		return

	# 2. Teorema de Nyquist: a maior frequência física detectável em um sinal digital
	# é exatamente metade da taxa de amostragem (mix rate).
	# Exemplo: Com taxa de 44.100 Hz, o Nyquist é 22.050 Hz.
	var nyquist: float = AudioServer.get_mix_rate() / 2.0
	
	# 3. Calcula a largura de cada fatia (bin) em Hz.
	# A FFT divide o intervalo de 0 Hz até Nyquist em (FFT_SIZE / 2) partes iguais.
	hz_por_bin = nyquist / (FFT_SIZE / 2.0)
	
	# 4. Inicia a reprodução se houver uma música atribuída ao Stream
	if music_player.stream:
		music_player.play()
	else:
		push_warning("Aviso: Nenhum arquivo de áudio (AudioStream) foi configurado no nó MusicPlayer.")


func _process(_delta: float) -> void:
	# DICA DE USO:
	# O _process é onde você chamará a leitura do espectro a cada frame para animar nós na tela.
	# Exemplo:
	# if spectrum_analyzer:
	#     var bandas = getSpectrumFrequencyBands(16)
	#     minha_barra_3d.scale.y = 1.0 + bandas[0] * 5.0
	pass


## Converte a magnitude linear da FFT em Decibéis (dB) e normaliza para o intervalo [0.0, 1.0].
## A percepção humana de volume é logarítmica, logo converter para dB produz uma reação visual muito mais natural.
func calcular_energia_normalizada(magnitude_linear: float) -> float:
	# Evita cálculo de logaritmo de zero (ou números negativos), que geraria -Infinito / NaN
	if magnitude_linear <= 0.0:
		return 0.0
		
	# Converte a amplitude linear da onda para a escala logarítmica de decibéis (dB)
	var magnitude_db: float = linear_to_db(magnitude_linear)
	
	# Mapeia a faixa de [-MIN_DB dB, 0 dB] para uma escala linear de [0.0, 1.0]:
	# - Se magnitude_db for 0 dB (volume máximo) -> (-60 + 60) / 60 = 1.0
	# - Se magnitude_db for -60 dB (muito baixo) -> (0) / 60 = 0.0
	return clampf((MIN_DB + magnitude_db) / MIN_DB, 0.0, 1.0)


## Retorna um Array contendo a energia normalizada de cada bin individual
## entre a frequência inicial (min_hz) e final (max_hz).
func getAmplitudeInFrequencyRange(min_hz: float, max_hz: float) -> Array[float]:
	var amplitudes: Array[float] = []
	var hz_atual: float = min_hz
	
	while hz_atual < max_hz:
		# Define o próximo passo sem ultrapassar o limite max_hz informado
		var proximo_hz: float = minf(hz_atual + hz_por_bin, max_hz)
		
		# A Godot retorna um Vector2 com a magnitude: (x = canal esquerdo, y = canal direito)
		var magnitude_vetor: Vector2 = spectrum_analyzer.get_magnitude_for_frequency_range(hz_atual, proximo_hz)
		
		# .length() calcula a intensidade combinada (magnitude vetorial estéreo)
		var energia: float = calcular_energia_normalizada(magnitude_vetor.length())
		amplitudes.append(energia)
		
		hz_atual += hz_por_bin
		
	return amplitudes


## Semelhante a getAmplitudeInFrequencyRange, mas permite escolher qual canal estéreo analisar:
## - channel = 0: Canal Esquerdo (Left)
## - channel = 1: Canal Direito (Right)
## - channel = -1 (ou qualquer outro): Média/Magnitude combinada de ambos os canais
func getSpectrumFrequenciesInRange(min_hz: float, max_hz: float, channel: int = -1) -> Array[float]:
	var amplitudes: Array[float] = []
	var hz_atual: float = min_hz
	
	while hz_atual < max_hz:
		var proximo_hz: float = minf(hz_atual + hz_por_bin, max_hz)
		var magnitude_vetor: Vector2 = spectrum_analyzer.get_magnitude_for_frequency_range(hz_atual, proximo_hz)
		
		var energia: float = 0.0
		if channel == 0:
			energia = calcular_energia_normalizada(magnitude_vetor.x) # Canal Esquerdo
		elif channel == 1:
			energia = calcular_energia_normalizada(magnitude_vetor.y) # Canal Direito
		else:
			energia = calcular_energia_normalizada(magnitude_vetor.length()) # Mix estéreo
			
		amplitudes.append(energia)
		hz_atual += hz_por_bin
		
	return amplitudes


## Divide o espectro musical (de 0 Hz até FREQ_MAX) em N bandas contínuas.
## É a função ideal para criar equalizadores gráficos de barras (ex: 8, 16 ou 32 barras).
## Retorna um Array[float] onde cada índice representa a energia daquela banda [0.0 a 1.0].
func getSpectrumFrequencyBands(n_bands: int) -> Array[float]:
	var energia_das_bandas: Array[float] = []
	energia_das_bandas.resize(n_bands) # Pré-aloca espaço para evitar realocações dinâmicas
	var freq_anterior: float = 0.0
	
	for i in range(n_bands):
		# Calcula a frequência de corte superior da banda atual
		var freq_atual: float = (i + 1) * FREQ_MAX / n_bands
		
		# Consulta a magnitude média acumulada na faixa [freq_anterior, freq_atual]
		var magnitude_vetor: Vector2 = spectrum_analyzer.get_magnitude_for_frequency_range(freq_anterior, freq_atual)
		
		energia_das_bandas[i] = calcular_energia_normalizada(magnitude_vetor.length())
		freq_anterior = freq_atual
		
	return energia_das_bandas


## Retorna uma lista com os limites em Hertz de cada uma das N bandas calculadas.
## Útil para fins de debug ou para identificar quais faixas de Hz correspondem a cada barra.
func getBandFrequencies(n_bands: int) -> Array[float]:
	var limites_freq: Array[float] = []
	limites_freq.resize(n_bands)
	for i in range(n_bands):
		limites_freq[i] = (i + 1) * FREQ_MAX / n_bands
	return limites_freq
