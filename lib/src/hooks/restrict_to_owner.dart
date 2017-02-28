import 'dart:mirrors';
import 'package:angel_framework/angel_framework.dart';
import 'errors.dart';
import 'is_server_side.dart';

/// Restricts users to accessing only their own resources.
HookedServiceEventListener restrictToOwner(
    {String idField,
    String ownerField,
    userKey,
    String errorMessage,
    getId(user),
    getOwner(obj)}) {
  return (HookedServiceEvent e) async {
    if (!isServerSide(e)) {
      var user = e.request?.grab(userKey ?? 'user');

      if (user == null)
        throw new AngelHttpException.notAuthenticated(
            message:
                'The current user is missing. You must not be authenticated.');

      _getId(user) {
        if (getId != null)
          return getId(user);
        else if (user is Map)
          return user[idField ?? 'id'];
        else if (user is Extensible)
          return user.properties[idField ?? 'id'];
        else if (idField == null || idField == 'id')
          return user.id;
        else
          return reflect(user).getField(new Symbol(idField ?? 'id')).reflectee;
      }

      var id = await _getId(user);

      if (id == null) throw new Exception('The current user has no ID.');

      var resource = await e.service.read(
          e.id,
          {}
            ..addAll(e.params ?? {})
            ..remove('provider'));

      if (resource != null) {
        _getOwner(obj) {
          if (getOwner != null)
            return getOwner(obj);
          else if (obj is Map)
            return obj[ownerField ?? 'userId'];
          else if (obj is Extensible)
            return obj.properties[ownerField ?? 'userId'];
          else if (ownerField == null || ownerField == 'userId')
            return obj.userId;
          else
            return reflect(obj)
                .getField(new Symbol(ownerField ?? 'userId'))
                .reflectee;
        }

        var ownerId = await _getOwner(resource);

        if ((ownerId is Iterable && !ownerId.contains(id)) || ownerId != id)
          throw new AngelHttpException.forbidden(
              message: errorMessage ?? Errors.INSUFFICIENT_PERMISSIONS);
      }
    }
  };
}
