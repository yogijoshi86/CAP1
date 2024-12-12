using time as service from '../../srv/time';
annotate service.time_attendance_reporting with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : '_c0',
                Value : _c0,
            },
            {
                $Type : 'UI.DataField',
                Label : '_c1',
                Value : _c1,
            },
            {
                $Type : 'UI.DataField',
                Label : '_c2',
                Value : _c2,
            },
            {
                $Type : 'UI.DataField',
                Label : '_c3',
                Value : _c3,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : '_c0',
            Value : _c0,
        },
        {
            $Type : 'UI.DataField',
            Label : '_c1',
            Value : _c1,
        },
        {
            $Type : 'UI.DataField',
            Label : '_c2',
            Value : _c2,
        },
        {
            $Type : 'UI.DataField',
            Label : '_c3',
            Value : _c3,
        },
    ],
);

