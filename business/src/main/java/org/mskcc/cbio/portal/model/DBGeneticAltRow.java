/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.mskcc.cbio.portal.model;

import java.io.Serializable;

/**
 *
 * @author abeshoua
 */
public class DBGeneticAltRow implements Serializable {
    public String genetic_profile_id;
    public String entrez_gene_id;
    public String hugo_gene_symbol;
    public String values;
    public String study_id;
}
