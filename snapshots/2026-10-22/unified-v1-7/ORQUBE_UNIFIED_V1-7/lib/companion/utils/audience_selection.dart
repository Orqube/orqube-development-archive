Set<String> eligibleGroupMembers(Iterable<String> group, Set<String> accepted) => group.where(accepted.contains).toSet();
bool validAudience(Set<String> live, Set<String> search, Set<String> accepted) => live.length <= 50 && accepted.containsAll(live) && live.containsAll(search);
