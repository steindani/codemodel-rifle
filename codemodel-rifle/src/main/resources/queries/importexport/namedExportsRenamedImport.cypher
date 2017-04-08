MATCH
// export.js: export { name1 };
    (exporter:CompilationUnit)-[:contains]->(:ExportDeclaration)-[:namedExports]->(exportSpecifier:ExportSpecifier),
    (exporter)-[:contains]->(exportedVariable:Variable)-[:declarations]->(declarationListToMerge:List)
        -->(declarationToMerge:Declaration)-[:node]->(exportBindingIdentifierToMerge:BindingIdentifier),

// import.js: import { name1 as exportedName1 } from "export";
    (importer:CompilationUnit)-[:contains]->(importedVariable:Variable)-[:declarations]->(declarationListToDelete:List)
        -->(declarationToDelete:Declaration)-[:node]->(importBindingIdentifierToDelete:BindingIdentifier)
        <-[:binding]-(importSpecifier:ImportSpecifier)<-[:namedImports]-(importDeclaration:ImportDeclaration)

    WHERE
    exporter.parsedFilePath CONTAINS importDeclaration.moduleSpecifier
    AND exportSpecifier.exportedName = exportedVariable.name
    AND exportedVariable.name = importSpecifier.name

CREATE UNIQUE
    (importedVariable)-[:declarations]->(declarationToMerge),
    (importedVariable)-[:declarations]->(declarationListToMerge),
    (importSpecifier)-[:binding]->(exportBindingIdentifierToMerge)

DETACH DELETE
declarationToDelete,
declarationListToDelete,
importBindingIdentifierToDelete
;
