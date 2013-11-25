% vim: set ft=prolog:

% Neste arquivo estão especificados os predicados que devem ser implementados.
% Você pode criar predicados auxiliares quando necessário.
%
% No arquivo resame_testes.pl estão os testes para alguns predicados.
%
% Para implementar cada predicado, primeiro você deve ler e entender a
% especificação e o teste.
%
% A especificação dos parâmetros dos predicados segue o formato descrito em
% http://www.swi-prolog.org/pldoc/doc_for?object=section%282,%274.1%27,swi%28%27/doc/Manual/preddesc.html%27%29%29
%
% Um Jogo same é representado por uma lista de colunas, sem os elementos nulos
% (zeros).
% Por exemplo, o jogo
% 2 | 3 0 0 0
% 1 | 2 2 2 0
% 0 | 2 3 3 1
% --+--------
%   | 0 1 2 3
% é representado como [[2, 2, 3], [3, 2], [3, 2], [1]].
% O tamanho deste jogo é 3x4 (linhas x colunas).
%
% Uma posição no jogo é representado por uma estrutura pos com dois argumentos
% (lin, col), onde lin é o número da linha e col é o número da coluna.  No
% exemplo anterior, a posição pos(0, 1) tem cor 3, e a posição pos(1, 2) tem
% cor 2.

% Você pode utilizar os predicados definidos no arquivo resame_utils.pl
:- consult(resame_utils).

%% main(+File) is det
%
%  Carrega um jogo same do arquivo File e imprime uma resolução na saída padrão
%  ou sem-solucao se o jogo não tem solução.

print_lin(_,4,_).

print_lin(Same,L,C) :-
	L1 is L+1,
	L1 < 5,
	elem(Same,pos(C,L),A),
	nonvar(A),
	write(A),
	write(' '),
	print_lin(Same,L1,C).

print_lin(Same,L,C) :-
	L1 is L+1,
	L1 < 5,
	not(elem(Same,pos(C,L),_)),
	write('0 '),
	print_lin(Same,L1,C).


print_Same(Same) :-
	print_lin(Same,0,3),
	writeln(''),
	print_lin(Same,0,2),
	writeln(''),
	print_lin(Same,0,1),
	writeln(''),
	print_lin(Same,0,0),
	writeln('').

printsol(_,[]).

printsol(Same, [A|B]) :-
    A = pos(X,Y),
    write(X),
    write(' '),
    writeln(Y),
    writeln(''),
    group(Same, A, Group),
    remove_group(Same, Group, NewSame),
    print_Same(NewSame),
    printsol(NewSame,B).

main(File) :-
    read_matrix_file(File, M),
    transpose(M,T),
    solve(T, S),
    printsol(T,S), !.

%% solve(+Same, -Moves) is nondet
%
%  Verdadeiro se Moves é uma sequência de jogadas (lista de posições) que
%  quando realizadas ("clicadas") resolvem o jogo Same.
%  Este predicado não tem teste de unidade. Ele é testado pelo testador.

solve([], []).
solve(Same, [M|Moves]) :-
    group(Same, Group),
    remove_group(Same, Group, NewSame),
    [M|_] = Group,
    solve(NewSame, Moves).

%% group(+Same, ?Group) is nondet
%
%  Verdadeiro se Group é um grupo de Same. Group é uma lista de posições
%  (estrutura pos(lin,col)). Este predicado é não determinístico e deve ser
%  capaz de gerar todos os grupos de Same. Este predicado não deve gerar grupos
%  repetidos. Este predicado e group/3 para vão utilizar os mesmos precicados
%  auxiliares.

group(Same, Group) :-
	gerador(Same, pos(0,0), Group).

gerador(Same, P, Sorted) :-
	group(Same, P, Group),
	length(Group,L),
	L > 1,
	sort(Group, Sorted).

gerador(Same, pos(X, Y), Group) :-
	X1 is X + 1,
	X1 < 4,
	gerador(Same, pos(X1, Y), Group),
	not(previous_elem(Group, pos(X1,Y))).

gerador(Same, pos(0, Y), Group) :-
	Y1 is Y + 1,
	Y1 < 4,
	gerador(Same, pos(0, Y1), Group),
	not(previous_elem(Group, pos(0,Y1))).


previous_elem([pos(_,Y)|_],pos(_,Y1)) :-
	Y < Y1.

previous_elem([pos(X,Y)|_],pos(X1,Y1)) :-
	Y = Y1,
	X < X1.

previous_elem([_|B],C) :-
	previous_elem(B, C).

%% grupo(+Same, +P, -Group) is semidet
%
%  Verdadeiro se Group é um grupo de Same que contém a posição P.

group(Same, P, Group) :-
    elem(Same, P, C),
    visita(Same, C, [P], [], [], Group).

%% visita(Same, C, Candidatos, Grupo) is semidet
%
%

% Verdadeiro se el está em uma das 2 listas.
elem_of(El, A, B) :-
	append(A, B, C),
	member(El, C).

remove_iguais([], _, []).

remove_iguais([A|B], G, New) :-
	elem_of(A,G,B),
	remove_iguais(B, G, New).

remove_iguais([A|B], G, [A|New]) :-
	not(elem_of(A,G,B)),
	remove_iguais(B, G, New).

visita( _, _, [], Grupo, _, Grupo).

visita(Same, C, [A|B], Grupo, Visit, NewGrup2) :-
	elem(Same, A, C),
	Visit1 = [A|Visit],
	NewGrup = [A|Grupo],
	A = pos(X,Y),
	X1 is X+1,
	X2 is X-1,
	Y1 is Y+1,
	Y2 is Y-1,
	Candidatos = [pos(X1,Y),pos(X2,Y),pos(X,Y1),pos(X,Y2)|B],
	remove_iguais(Candidatos, Visit1, NewCand),
	visita(Same, C, NewCand, NewGrup, Visit1, NewGrup2).

visita(Same, C, [A|B], Grupo, Visit, NewGrup) :-
	not(elem(Same, A, C)),
	Visit1 = [A|Visit],
	visita(Same, C, B, Grupo, Visit1, NewGrup).

%% elem(+Same, +P, -C) is semidet
%
% Verdadeiro se C é a cor do elemento P de Same

elem([[A|_]|_], pos(0, 0), A).

elem([[_|R]|_], pos(B, 0), C) :-
	B > 0,
	B1 is B - 1,
	elem([R|_], pos(B1, 0), C).

elem([_|R], pos(X, Y), C) :-
	Y > 0,
	Y1 is Y - 1,
	elem(R,pos(X,Y1),C).

%% remove_group(+Same, +Group, -NewSame) is semidet
%
%  Verdadeiro se NewSame é obtido de Same removendo os elemento especificados
%  em Group. A remoção é feita de acordo com as regras do jogo same.
%  Dica:
%    - crie um predicado auxiliar remove_column_group, que remove os elementos
%    de uma coluna específica

arrasta_cols([],[]).

arrasta_cols([[]|B], C) :-
	arrasta_cols(B,C).

arrasta_cols([A|B],[A|C]) :-
	length(A,L),
	L > 0,
	arrasta_cols(B,C).

remove_group(Same, Group, NewSame2) :-
	sort(Group,Sorted),
	reverse(Rev,Sorted),
	remove_group2(Same, Rev, NewSame),
        arrasta_cols(NewSame, NewSame2).

remove_group2(Same, [], Same).

remove_group2(Same, [A|B], NewSame) :-
	remove_pos(Same, A, NewSame1),
	remove_group2(NewSame1, B, NewSame).

remove_pos([[_|A]|B], pos(0,0), [A|B]).

remove_pos([[A|B]|C], pos(X,0), [[A|N]|C]) :-
	X > 0,
	X1 is X - 1,
	remove_pos([B|_], pos(X1,0), [N|_]).

remove_pos([A|B], pos(X,Y), [A|N]) :-
	Y > 0,
	Y1 is Y - 1,
	remove_pos(B, pos(X,Y1), N).
