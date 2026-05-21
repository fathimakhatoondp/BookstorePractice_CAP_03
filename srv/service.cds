using {tutorial.db as db} from '../db/schema';

service BookstoreService {
    @(restrict: [{
        grant: [
            'READ',
            'WRITE',
            'UPDATE',
            'DELETE'
        ],
        to   : 'admin'
    },{
        grant: 'READ',
        to : 'authenticated-users'
    },{
        grant : ['READ','DELETE'],
        to    : 'user-with-action-permissions'
    }])
    entity Books      as projection on db.Books
        actions {
            @(Common.SideEffects: {TargetProperties: ['stock']})
            action addStock();
            @(Common.SideEffects: {TargetProperties: ['publishedAt']})
            action changePublishedDate(newDate: Date);
            @(Common.SideEffects: {TargetProperties: ['status_code']})
            action changeStatus( @(Common: {
                                     ValueListWithFixedValues: true,
                                     Label                   : 'New Status',
                                     ValueList               : {
                                         $Type         : 'Common.ValueListType',
                                         CollectionPath: 'BookStatus',
                                         Parameters    : [{
                                             $Type            : 'Common.ValueListParameterInOut',
                                             LocalDataProperty: newStatus,
                                             ValueListProperty: 'code',
                                         }, ],
                                     },
                                 }) newStatus: String);
        };

    @(
        Common.SideEffects: {TargetEntities: ['/BookstoreService.EntityContainer/Books']},
        requires          : 'user-with-action-permissions'
    )
    action discount();

    entity Authors    as projection on db.Authors;
    entity Chapters   as projection on db.Chapters;
    entity BookStatus as projection on db.BookStatus;
    entity GenresVH   as projection on db.Genres;
}

annotate BookstoreService.Books with @odata.draft.enabled;

annotate BookstoreService.Authors with @(
    odata.draft.enabled,
    requires: 'admin'
);
