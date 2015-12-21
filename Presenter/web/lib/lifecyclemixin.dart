library lifecycle;

///Mixin to track Lifecycle of an object.
abstract class LifecycleTracker{
    DateTime _created;
    DateTime _edited;
    
    recordCreateTimestamp() => _created = new DateTime.now();
    updateEditTimestamp() => _edited = new DateTime.now();
    
    DateTime get created => _created;
    DateTime get lastEdited => _edited;
}