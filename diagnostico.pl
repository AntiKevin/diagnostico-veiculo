/*********************************************
 * 1. DECLARAÇÃO DE PREDICADOS DINÂMICOS
 *********************************************/
:- dynamic(bateria/1).
:- dynamic(temperatura_motor/1).
:- dynamic(nivel_oleo/1).
:- dynamic(sensor_oxigenio/1).
:- dynamic(luz_check_engine/0).
:- dynamic(luz_bateria/0).
:- dynamic(falha_ignicao/0).
:- dynamic(barulho_incomum/0).
:- dynamic(rotacao_alta/0).


/*********************************************
 * 2. FATOS BÁSICOS (SINTOMAS E CAUSAS)
 *    - Aqui definimos sintomas e as possíveis
 *      causas associadas a cada um deles. (não mexer)
 *********************************************/

/* Exemplos de causas representadas por termos que
   indicam possíveis problemas */
causa(bateria_fraca).
causa(alternador_defeituoso).
causa(sistema_arrefecimento).
causa(baixo_nivel_oleo).
causa(vela_ignicao_defeituosa).
causa(sensor_oxigenio_defeituoso).
causa(problema_injecao).
causa(problema_transmissao).
causa(problema_interno_motor).  % Ex.: biela, pistão, etc.

/*********************************************
 * 3. REGRAS DE DIAGNÓSTICO PRINCIPAIS
 *    - Se determinados sintomas e leituras
 *      de sensores estiverem presentes,
 *      inferimos a causa provável.
 *********************************************/

% 3.1 Diagnóstico de bateria fraca
%    - Se há falha de ignição, luz de bateria acesa
%      e tensão da bateria < 12, conclui-se bateria_fraca.
diagnostico(bateria_fraca) :-
    falha_ignicao,
    luz_bateria,
    bateria(Voltage),
    Voltage < 12.

% 3.2 Diagnóstico de alternador defeituoso
%    - Se a bateria está fraca mesmo após recarga,
%      ou se a luz de bateria acende durante o uso,
%      suspeita do alternador.
diagnostico(alternador_defeituoso) :-
    luz_bateria,
    \+ diagnostico(bateria_fraca).
    /* Se não foi diagnosticada bateria_fraca,
       mas a luz continua acesa, pode ser alternador. */

% 3.3 Diagnóstico de superaquecimento / sistema de arrefecimento
%    - Se temperatura do motor > 100°C e/ou check engine aceso,
%      indicamos problema de arrefecimento.
diagnostico(sistema_arrefecimento) :-
    temperatura_motor(T),
    T > 100,
    (luz_check_engine ; true). % Check engine pode ou não estar acesa

% 3.4 Diagnóstico de baixo nível de óleo
%    - Se nível do óleo está abaixo do mínimo (ex: 2.0),
%      sugerimos problema relacionado ao óleo.
diagnostico(baixo_nivel_oleo) :-
    nivel_oleo(N),
    N < 2.0, % Definindo um limite mínimo como exemplo
    (luz_check_engine ; true). % Pode estar associado ao check engine

% 3.5 Diagnóstico de vela de ignição defeituosa
%    - Se há falha de ignição frequente, mas a bateria está boa,
%      suspeitamos da vela de ignição.
diagnostico(vela_ignicao_defeituosa) :-
    falha_ignicao,
    (bateria(V), V >= 12 ; \+ bateria(_)). % Bateria OK ou sem informação

% 3.6 Diagnóstico de sensor de oxigênio defeituoso
%    - Se o sensor de oxigênio marca valor fora da faixa normal (ex: > 0.9 ou < 0.1)
%      e a luz de check engine pisca (ou está acesa) em alta rotação,
%      pode ser o sensor de oxigênio.
diagnostico(sensor_oxigenio_defeituoso) :-
    rotacao_alta,
    luz_check_engine,
    sensor_oxigenio(O),
    (O > 0.9 ; O < 0.1). % Faixa normal exemplo: 0.1 a 0.9

% 3.7 Diagnóstico de problema na injeção
%    - Se há falha em alta rotação e a leitura do sensor de
%      oxigênio está na faixa normal, mas check engine acesa,
%      pode ser a injeção.
diagnostico(problema_injecao) :-
    rotacao_alta,
    luz_check_engine,
    sensor_oxigenio(O),
    O >= 0.1, O =< 0.9, % Sensor OK
    \+ diagnostico(sensor_oxigenio_defeituoso).

% 3.8 Diagnóstico de ruídos no motor (problema interno ou transmissão)
%    - Se há barulho incomum e perda de potência, mas a check engine
%      não acende, pode ser mecânico (bielas, transmissão etc.).
diagnostico(problema_interno_motor) :-
    barulho_incomum,
    \+ luz_check_engine,
    temperatura_motor(T),
    T < 100,  % Temperatura normal
    % Adicionar mais condições para diferenciar de transmissão se necessário
    !.

diagnostico(problema_transmissao) :-
    barulho_incomum,
    % Condições específicas de transmissão (ex: ruído ao trocar marcha)
    % Aqui, simplificamos: se não for interno e houver barulho, pode ser transmissão
    \+ diagnostico(problema_interno_motor).

/*********************************************
 * 4. RECOMENDAÇÕES DE AÇÃO
 *    - Associa cada causa a uma recomendação
 *      de manutenção / correção.
 *********************************************/
recomendacao(bateria_fraca, 'Recarregar ou substituir a bateria').
recomendacao(alternador_defeituoso, 'Verificar correia do alternador ou trocar alternador').
recomendacao(sistema_arrefecimento, 'Checar radiador, bomba d\'água, ventoinha e fluido de arrefecimento').
recomendacao(baixo_nivel_oleo, 'Completar nível de óleo ou verificar vazamentos').
recomendacao(vela_ignicao_defeituosa, 'Substituir vela de ignição').
recomendacao(sensor_oxigenio_defeituoso, 'Substituir sensor de oxigênio').
recomendacao(problema_injecao, 'Verificar sistema de injeção e bicos injetores').
recomendacao(problema_interno_motor, 'Levar a um mecânico para verificar bielas, pistões e outros componentes internos').
recomendacao(problema_transmissao, 'Verificar fluido de transmissão e componentes mecânicos da transmissão').

/*********************************************
 * Implementação do predicado list_to_set/2 para GNU Prolog
 * (já que este não possui o predicado na biblioteca padrão)
 *********************************************/
% Remove duplicatas de uma lista
list_to_set([], []).
list_to_set([H|T], [H|T1]) :- 
    delete_all(H, T, T2),
    list_to_set(T2, T1).

% Remove todas as ocorrências de X em uma lista
delete_all(_, [], []).
delete_all(X, [X|T], T1) :- 
    delete_all(X, T, T1).
delete_all(X, [H|T], [H|T1]) :- 
    X \= H,
    delete_all(X, T, T1).

/*********************************************
 * 5. PREDICADO PRINCIPAL DE DIAGNÓSTICO
 *    - Identifica todas as causas possíveis,
 *      exibe as recomendações. (não mexer)
 *********************************************/
diagnosticar :-
    % Encontra todas as causas que satisfazem as regras
    findall(Causa, diagnostico(Causa), ListaCausasRaw),
    list_to_set(ListaCausasRaw, ListaCausasUnicas), % Remove duplicatas
    (   ListaCausasUnicas \= []
    ->  format("Possiveis problemas diagnosticados: ~w~n",[ListaCausasUnicas]),
        listar_recomendacoes(ListaCausasUnicas)
    ;   write("Nenhum problema foi diagnosticado com as informacoes atuais."), nl
    ).

listar_recomendacoes([]).
listar_recomendacoes([Causa|Resto]) :-
    recomendacao(Causa, Rec),
    format(' -> Para ~w, recomenda-se: ~w~n', [Causa, Rec]),
    listar_recomendacoes(Resto).


/*********************************************
 * 6. EXEMPLOS DE CASOS DE TESTE
 *    - Cada cenário insere (assert) valores
 *      de sintomas e sensores, chama
 *      diagnosticar/0 e depois limpa o estado.
 * * (não mexer)
 *********************************************/
% Observação: Estes predicados são apenas exemplos
% de como testar. Ajuste conforme desejar.

caso_teste_1_partida_inconsistente :-
    write('=== Caso de Teste 1: Partida Inconsistente ==='), nl,
    limpar_estado,
    assertz(falha_ignicao),
    assertz(luz_bateria),
    assertz(bateria(11.8)),
    diagnosticar,
    limpar_estado.

caso_teste_2_superaquecimento :-
    write('=== Caso de Teste 2: Superaquecimento no Motor ==='), nl,
    limpar_estado,
    assertz(temperatura_motor(105)),
    assertz(nivel_oleo(1.5)), % Nível baixo (abaixo de 2.0)
    assertz(luz_check_engine),
    diagnosticar,
    limpar_estado.

caso_teste_3_motor_engasgado_altas_rotacoes :-
    write('=== Caso de Teste 3: Motor Engasgado em Altas Rotacoes ==='), nl,
    limpar_estado,
    assertz(rotacao_alta),
    assertz(luz_check_engine),
    assertz(sensor_oxigenio(1.0)), % valor fora do normal (> 0.9)
    diagnosticar,
    limpar_estado.

caso_teste_4_ruidos_ao_acelerar :-
    write('=== Caso de Teste 4: Ruidos no Motor ao Acelerar ==='), nl,
    limpar_estado,
    assertz(barulho_incomum),
    assertz(temperatura_motor(90)),  % dentro da faixa normal
    % Para testar 'problema_interno_motor' ou 'problema_transmissao'
    % pode ser necessário adicionar mais fatos ou refinar as regras 3.8
    diagnosticar,
    limpar_estado.

% Predicado para limpar o estado dinâmico antes/depois dos testes
limpar_estado :-
    retractall(bateria(_)),
    retractall(temperatura_motor(_)),
    retractall(nivel_oleo(_)),
    retractall(sensor_oxigenio(_)),
    retractall(luz_check_engine),
    retractall(luz_bateria),
    retractall(falha_ignicao),
    retractall(barulho_incomum),
    retractall(rotacao_alta).

:- initialization(main).

main :-
    write('=== Executando casos de teste selecionados ==='), nl,
    caso_teste_1_partida_inconsistente,
    nl,
    caso_teste_2_superaquecimento,
    nl,
    caso_teste_3_motor_engasgado_altas_rotacoes,
    nl,
    caso_teste_4_ruidos_ao_acelerar,
    nl,
    write('=== Fim dos testes ==='), nl,
    halt.