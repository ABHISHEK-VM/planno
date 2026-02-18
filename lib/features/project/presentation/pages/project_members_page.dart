import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/user_bloc/user_bloc.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../bloc/project_bloc.dart';

@RoutePage()
class ProjectMembersPage extends StatelessWidget {
  final ProjectEntity project;

  const ProjectMembersPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProjectBloc>()..add(ProjectLoadAll()),
        ),
      ],
      child: _ProjectMembersView(project: project),
    );
  }
}

class _ProjectMembersView extends StatelessWidget {
  final ProjectEntity project;

  const _ProjectMembersView({required this.project});

  void _showAddMemberDialog(BuildContext context) {
    print('ProjectMembersPage: Showing Add Member Dialog');
    final projectBloc = context.read<ProjectBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider(
          create: (context) => getIt<UserBloc>(),
          child: _AddMemberDialog(project: project, projectBloc: projectBloc),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        // No need to fetch users anymore, the project entity has the members.
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Project Members')),
        body: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            List<MemberEntity> members = project.members;
            if (state is ProjectLoaded) {
              final updatedProject = state.projects
                  .cast<ProjectEntity>()
                  .firstWhere((p) => p.id == project.id, orElse: () => project);
              members = updatedProject.members;
            }

            if (members.isEmpty) {
              return const Center(child: Text('No members found.'));
            }
            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(member.name[0].toUpperCase()),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.email),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMemberDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  final ProjectEntity project;
  final ProjectBloc projectBloc;

  const _AddMemberDialog({required this.project, required this.projectBloc});

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Member'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.read<UserBloc>().add(
                      SearchUsers(_searchController.text),
                    );
                  },
                ),
              ),
              onSubmitted: (query) {
                context.read<UserBloc>().add(SearchUsers(query));
              },
            ),
            SizedBox(height: 10.h),
            Flexible(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserSearchLoading) {
                    return const LinearProgressIndicator();
                  } else if (state is UserSearchResults) {
                    if (state.users.isEmpty) {
                      return const Text('No users found.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        final isAlreadyMember = widget.project.memberIds
                            .contains(user.id);

                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: isAlreadyMember
                              ? const Icon(Icons.check, color: Colors.green)
                              : IconButton(
                                  icon: const Icon(Icons.person_add),
                                  onPressed: () {
                                    widget.projectBloc.add(
                                      ProjectAddMember(
                                        projectId: widget.project.id,
                                        member: MemberEntity(
                                          id: user.id,
                                          name: user.name,
                                          email: user.email,
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Member added!'),
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                    );
                  } else if (state is UserError) {
                    return Text(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
