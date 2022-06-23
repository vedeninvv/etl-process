import pandas as pd
from IPython.display import SVG
from bokeh.models import HoverTool
from bokeh.plotting import figure, save
from bokeh.plotting import show, ColumnDataSource
from chembl_webresource_client.new_client import new_client
from rdkit import Chem
from rdkit.Chem import AllChem
from rdkit.Chem import PandasTools
from rdkit.Chem import rdDepictor
from rdkit.Chem.Draw import rdMolDraw2D
from rdkit.Chem.PandasTools import ChangeMoleculeRendering
from sklearn.manifold import TSNE


def processing_molecule(molecule, kekulize):
    mc = Chem.Mol(molecule.ToBinary())
    if kekulize:
        try:
            Chem.Kekulize(mc)
        except:
            mc = Chem.Mol(molecule.ToBinary())
    if not mc.GetNumConformers():
        rdDepictor.Compute2DCoords(mc)
    return mc


def molecule_to_svg(molecule, molecule_size=(450, 200), kekulize=True, drawer=None, **kwargs):
    mc = processing_molecule(molecule, kekulize)
    if drawer is None:
        drawer = rdMolDraw2D.MolDraw2DSVG(molecule_size[0], molecule_size[1])
    drawer.DrawMolecule(mc, **kwargs)
    drawer.FinishDrawing()
    svg = drawer.GetDrawingText()
    return SVG(svg.replace('svg:', ''))


molecule = new_client.molecule
approved_drugs = molecule.filter(max_phase=4)
molecule_drugs = [x for x in approved_drugs if x['molecule_type'] == 'Small molecule']

struct_list = [(x['pref_name'], x['molecule_chembl_id'], x['molecule_structures']) for x in molecule_drugs if x]
chem_formula_list = [(a, b, c['canonical_smiles']) for (a, b, c) in struct_list if c]

chem_formula_df = pd.DataFrame(chem_formula_list)
chem_formula_df.columns = ['Name', 'ChEMBL_ID', 'FORMULA']

PandasTools.AddMoleculeColumnToFrame(chem_formula_df, smilesCol='FORMULA')

ECFP4_fps = [AllChem.GetMorganFingerprintAsBitVect(x, 2) for x in chem_formula_df['ROMol']]

tsne = TSNE(random_state=0).fit_transform(ECFP4_fps)

svgs = [molecule_to_svg(m).data for m in chem_formula_df.ROMol]

ChangeMoleculeRendering(renderer='PNG')

source = ColumnDataSource(data=dict(x=tsne[:, 0], y=tsne[:, 1], desc=chem_formula_df.Name,
                                    svgs=svgs))

hover = HoverTool(tooltips="""
    <div>
        <div>@svgs{safe}
        </div>
        <div>
            <span style="font-size: 20px;">@desc</span>
        </div>
    </div>
    """
                  )
visualization = figure(plot_width=1400, plot_height=1000,
                       tools=[hover],
                       title="Molecule visualization")

visualization.circle('x', 'y', size=5, source=source, fill_alpha=0.2)

save(visualization)
show(visualization)