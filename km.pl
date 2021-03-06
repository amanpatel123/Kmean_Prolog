%% Name: Shivani Pansara
%% StudentID: 104874374
%% Name: Aman Patel
%% StudentID: 104956768


%%% This is the main program which we will run
%%% Input: DataSet(of any dimention), K 
%%% Output: Clusters
%%% kmean([[1.0, 2.0], [2.0, 3.0], [3.0, 4.0], [4.0, 5.0], [5.0, 6.0]], 2, Clusters).
%%% [[[1.0, 2.0], [2.0, 3.0], [3.0, 4.0]], [[4.0, 5.0], [5.0, 6.0]]]
kmean(DataSet, 1, [DataSet]).
kmean(DataSet, K, DataSet) :- 
		length(DataSet, L),
		L =:= K,
		!.
kmean(DataSet, K, Clusters):-
		length(DataSet, L),
		L @> K, !,
		init(DataSet, K, Centroids),
		begin_clustering(DataSet, Centroids, K, [], ClusterMap),
		cluster_mapping(ClusterMap, DataSet, 0, K, Clusters).


%%% initRandom()
%% initRandom takes in DataSet, K and returns a list containing k initial centroids which are chooses at random
%% Return value looks something like this: 
%% [[x1, y1], [x2, y2],...... ,[xk, yk]]
initRandom(DataSet, K, [H|Centroids]) :- 
		K > 0,
		length(DataSet, L),
		random(0, L, Index),
		nth0(Index, DataSet, H),
		delete(DataSet, H, UpdatedDataset),
		I is K-1,
		init(UpdatedDataset, I, Centroids).
		
%%% init()
%%% init takes in DataSet, K and returns a list containing k initial centroids. Kmean++ algorithm is used for initialization
%%% init([[1, 1], [2, 2], [2, 3], [5, 2]], 2, C).
init(DataSet, K, Centroids) :-
		K > 0,
		length(DataSet, L),
    random(0, L, Index),
    nth0(Index, DataSet, H),
		Kn is K - 1,
		init_rest(DataSet, Kn, [H], Centroids).
		
	
%%% initialize the rest k-1 centroids
%%% init_rest([[1, 1], [2, 2], [2, 3], [5, 2]], 2, [[1, 1]], C).
init_rest(DataSet, N, AlreadySelectedCentroids, Centroids) :-
		N @> 0,
		get_distance_map(DataSet, AlreadySelectedCentroids, DistanceMap),
		max_list(DistanceMap, Max),
		nth0(IndexOfMax, DistanceMap, Max),
		nth0(IndexOfMax, DataSet, Vertex),
		append(AlreadySelectedCentroids, [Vertex], NewSelectedCentroids),
		!,
		Nk is N - 1,
		init_rest(DataSet, Nk, NewSelectedCentroids, Centroids).
init_rest(_,0,Centroids, Centroids).
		
				
%% get_distance_map()
%% Returns an array which contains the distance of each datapoint from its nearest centroids 
%% get_distance_map([[0,0], [1, 1], [2, 2]], [[1, 1], [2, 2], [2, 3], [5, 2]], DM).
%% Should Return: DM = [1.4142135623730951, 0.0, 0.0]
get_distance_map([Vertex | DataSet], Centroids, [D | DistanceMap]) :-
		current_prolog_flag(max_integer, SYSTEM_MAX),
		get_min_distance_from_centroids(Vertex, SYSTEM_MAX, Centroids, D),
		get_distance_map(DataSet, Centroids, DistanceMap).
get_distance_map([], _, []).


%%% get_min_distance_from_centroids()
%%% Returns the distance of the Given Vertex from its nearest centroid
%%% get_min_distance_from_centroids([0,0], 1112122, [[1, 1], [2, 2], [2, 3], [5, 2]], D).
%%% Should return D = 1.4142135623730951
get_min_distance_from_centroids(Vertex, CurrentMin, [HC| Centroids], D):-
		euclidean_distance(Vertex, HC, R),
		R @< CurrentMin,
		!,
		get_min_distance_from_centroids(Vertex, R, Centroids, D).
get_min_distance_from_centroids(Vertex, CurrentMin, [_ | Centroids], D) :-
	!,
	get_min_distance_from_centroids(Vertex, CurrentMin, Centroids, D).
get_min_distance_from_centroids(_, D, [], D).


%%%% begin_clustering
%% Input: DataSet: example - [[1,2], [3, 4], [2, 3]]
%% InitialClusters: example - [] OR [ C1 = [[1, 2], [3, 4]], C2=[[2,3]] ]
%% Centroids: [cs1, cs2]
begin_clustering(DataSet, Centroids, K, PreviousClusterMap, ResultantClusterMap) :-
	get_cluster_map(DataSet, Centroids, UpdatedClusterMap),
	PreviousClusterMap \== UpdatedClusterMap, !, 
	centroids_calc(UpdatedClusterMap, DataSet, K, UpdatedCentroids),
	begin_clustering(DataSet, UpdatedCentroids, K, UpdatedClusterMap, ResultantClusterMap).
begin_clustering(_, _, _, PreviousClusterMap, PreviousClusterMap).


%%% get_cluster_map 
%%% (Outputs an array of size = |Dataset| consisting of the Clusters index corresponding to the Datapoints)
%%% Example output: [2, 3, 1, 1, 2, 2, 3], can be read as 1st datapoint belongs to 2nd cluster, 2nd datapoint belongs to 3rd and so on...
get_cluster_map([Vertex | DataSet], Centroids, [IndexOfCluster | ClusterMap]) :-
    !,
		current_prolog_flag(max_integer, SYSTEM_MAX),
    get_label(Vertex, Centroids, SYSTEM_MAX, [], Centroid),
		nth0(IndexOfCluster, Centroids, Centroid),
		get_cluster_map(DataSet, Centroids, ClusterMap).
get_cluster_map([],_, []).
	
%% get_label
%% Input: Vertex whose centroid needs to be found, array containing Centroids
%% Output: Result which is the Centroid which the Vertex belongs to 
get_label(Vertex, [Centroid | Centroids], CurrentMin, R, Result) :-
		euclidean_distance(Vertex, Centroid, D),
		D @< CurrentMin,
		!,
		get_label(Vertex, Centroids, D, Centroid, Result).
get_label(Vertex, [_ | Centroids], CurrentMin, R, Result) :-
		!,
		get_label(Vertex, Centroids, CurrentMin, R, Result).
get_label(_, [], _, Result, Result).


%%%% euclidean_distance()
%% takes two points and find the Euclidean distance i.e. squared distance sqrt((x2-x1)^2 + (y2-y1)^2).
euclidean_distance([X|T1], [Y|T2], Distance) :- 
		calculation(T1, T2, (Y-X)^2, S),
		Distance is sqrt(S). 


%%%% calculation()
%% find the square between two points and adds them i.e. (x2-x1)^2 + (y2-y1)^2
calculation([], [], I, I).
calculation([X|T1], [Y|T2], I0, I+I0) :-
		calculation(T1, T2, (Y-X)^2, I).
		



%%%% centroids_calc()
%% takes in the cluster map, datasets and number of clusters and gives away the new 
%% calculated centroids
%% Return value looks something like this if we have 3 clusters:
%% [[x1, y1], [x2, y2], [x3, y3]]
%% These are the three newly calculated centroids
centroids_calc(ClusterMap, DataSet, K, Centroids) :-
		cluster_mapping(ClusterMap, DataSet, 0, K, NewClusters),
		centroidlist(NewClusters, Centroids).


%%%% cluster_mapping()
%% takes the array of clusters and dataset and returs the list clustered into K parts
cluster_mapping(_, _, K, K, []) :- !.
cluster_mapping(ClusterMap, DataSet, Counter, K, [InitialCluster | ResultantCluster]) :-
		cluster_mapping_helper(ClusterMap, DataSet, Counter, 0, InitialCluster),
		SubCounter is Counter + 1,
		cluster_mapping(ClusterMap, DataSet, SubCounter, K, ResultantCluster).


%%%% cluster_mapping_helper()
%% this is the helper funciton for the above mapping function
%% it takes in the list of clusters and dataset and assign the datapoint from the dataset 
%% to a particular cluster depending on the list of clusters
cluster_mapping_helper([Counter | ClusterMap], DataSet, Counter, Index, [IndexElement | Resultant]) :-
		nth0(Index, DataSet, IndexElement),
		NextIndex is Index + 1, !,
		cluster_mapping_helper(ClusterMap, DataSet, Counter, NextIndex, Resultant).
cluster_mapping_helper([_ | ClusterMap], DataSet, Counter, Index, Resultant) :-
		NextIndex is Index + 1, !,
		cluster_mapping_helper(ClusterMap, DataSet, Counter, NextIndex, Resultant).
cluster_mapping_helper([], _, _, _, []).

%%%% centroidlist()
%% takes list of lists containing clusters and give the centroid for each cluster
centroidlist([X | T], [I | F]) :-
		centroid(X, I),
		centroidlist(T, F).
centroidlist([], []) :- !.


%%%% centroid
%% takes the datapoints of a cluster and returns the centroid for that particular cluster
centroid(DataSet, Centroid) :-
		list_add(DataSet, AddResult),
		length(DataSet, L),
		division(AddResult, L, Centroid).
centroid([], []).

%%%% list_add()
%% takes the list of lists and add the elements in it. It retursn the final sum 
list_add([X | T], Result) :-
		identity_func(X, ID),
		list_add([X | T], ID, Result).
list_add([X | T], ID, Result) :-
		addition(X, ID, Answer),
		list_add(T, Answer, Result).
list_add([], Result, Result).

%%%% identity_func()
%% gives the identity list for addition i.e. the list of zeros depending on the dimension of input
identity_func([_ | T], [0 | ID]) :-
		identity_func(T, ID).
identity_func([], []).

%%%% addition()
%% takes the datapoint and its identity function and perform the addition and return the result
addition([X1 | T1], [X2 | T2], [InitialAdd | Result]) :-
		InitialAdd is X1 + X2,
		addition(T1, T2, Result).
addition([], [], []).

%%%% division()
%% takes the list of result of addition of clusters and divide each result by the total length to get the centroid for that cluster 
division([X | T], L, [Quotient | Result]) :-
		Quotient is X / L,
		division(T, L, Result).
division([], _, []).
		
