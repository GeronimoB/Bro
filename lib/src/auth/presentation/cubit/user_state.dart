part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoading extends UserState {
  @override
  List<Object> get props => [];
}

class UserFailure extends UserState {
  final String message;

  const UserFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class UserSuccess extends UserState {
  @override
  List<Object> get props => [];
}