role Perl6::Metamodel::Mixins {
    method mixin($obj, *@roles) {
        # Work out a type name for the post-mixed-in role.
        my @role_names;
        for @roles { @role_names.push($_.HOW.name($_)) }
        my $new_name := self.name($obj) ~ '+{' ~
            pir::join(',', @role_names) ~ '}';
        
        # Create new type, derive it from ourself and then add
        # all the roles we're mixing it.
        my $new_type := self.new_type(:name($new_name));
        $new_type.HOW.add_parent($new_type, $obj.WHAT);
        for @roles {
            $new_type.HOW.add_role($new_type, $_);
        }
        $new_type.HOW.set_boolification_mode($new_type, self.get_boolification_mode($obj));
        $new_type.HOW.compose($new_type);
        
        # If the original object was concrete, change its type by calling a
        # low level op. Otherwise, we just return the new type object
        nqp::isconcrete($obj) ??
            pir::repr_change_type__0PP($obj, $new_type) !!
            $new_type
    }
}
